__all__ = ['ViewService']

import json
from datetime import timedelta

from django.conf import settings
from django.contrib.auth.hashers import make_password
from django.utils import timezone
from django.utils.crypto import get_random_string

from ninepm.app.ninepm_mobile_api.modules.common.base_service import \
    BaseViewService
from ninepm.common.models.model_ninepm import models, transaction


class ViewService(BaseViewService):

    def __init__(self) -> None:
        super().__init__()

    @staticmethod
    def __generate_token():
        return get_random_string(64)

    def __generate_otp(self):
        otp_length = settings.OTP_LENGTH
        otp = self._otp_generator.generate(otp_length)
        hashed_otp = make_password(otp)
        return otp, hashed_otp

    @staticmethod
    def __validate(request: models.LoginRequest):
        if request.status != models.LoginRequest.Status.NEW:
            raise NotImplementedError(
                'Tình trạng đăng nhập không hợp lệ. Vui lòng đăng nhập lại.')

        if timezone.now() < request.send_otp_at:
            raise NotImplementedError(
                'Thời gian gửi OTP quá nhanh. Vui lòng thử lại sau.')

    def send_otp_again(
        self,
        token: str,
    ):
        otp, hashed_otp = self.__generate_otp()

        with transaction.atomic():
            request = models.LoginRequest.objects.select_for_update().get(
                token=token,
            )

            self.__validate(request)

            request.retry_number = 0
            request.token_value = hashed_otp
            request.status = models.LoginRequest.Status.NEW
            request.otp_expired_at = timezone.now() + timedelta(
                seconds=settings.OTP_LIFETIME_IN_SECONDS)
            request.send_otp_at = timezone.now() + timedelta(
                seconds=settings.SEND_OTP_IN_SECONDS)
            request.save()

            return request.user.phone_number, request.token, otp

    def send_otp(
        self,
        phone_number: str,
        device_token: str,
    ):
        client = self._get_client()
        raw_data = client.get(device_token)

        otp_retry_number = 0
        if raw_data:
            data = json.loads(raw_data.decode('utf-8'))
            otp_retry_number = data['otp_retry_number']

        otp_retry_number += 1

        value = dict(otp_retry_number=otp_retry_number)
        ex = settings.OTP_RETRY_MAX_AGE
        client.set(device_token, json.dumps(value), ex=ex)

        # TODO: send sms
        pass
