__all__ = ['ViewService']

import json
import uuid

from django.conf import settings
from django.contrib.auth.hashers import check_password
from django.utils import timezone

from ninepm.app.ninepm_mobile_api.modules.common.base_service import \
    BaseViewService
from ninepm.app.ninepm_mobile_api.utils.conf import get_auth_conf
from ninepm.common.models.model_ninepm import models, transaction


class ViewService(BaseViewService):

    def __init__(self) -> None:
        super().__init__()

    @staticmethod
    def __validate(request: models.LoginRequest):
        if request.status != models.LoginRequest.Status.NEW:
            raise NotImplementedError(
                'Tình trạng đăng nhập không hợp lệ. Vui lòng đăng nhập lại.')

        if timezone.now() > request.otp_expired_at:
            raise NotImplementedError('Mã xác thực hết hạn.')

        if request.retry_number > settings.MAX_OTP_IS_RETRIED:
            raise NotImplementedError('Bạn nhập mã xác thực quá nhiều lần.')

    def validate_login_otp(
        self,
        token: str,
        otp: str,
        device_token: str,
    ):
        with transaction.atomic():
            try:
                request = models.LoginRequest.objects.select_for_update().get(
                    token=token
                )
            except models.LoginRequest.DoesNotExist:
                raise NotImplementedError(
                    'Mã xác thực không đúng. Vui lòng thử lại.')

            self.__validate(request)

            if not check_password(otp, request.token_value):
                request.retry_number += 1
                request.save()
                return None, None

            request.status = models.LoginRequest.Status.CLOSED
            request.result = models.LoginRequest.Result.SUCCESS
            request.save()

            models.FcmTokenMembership.objects.filter(
                device_token=device_token,
            ).update(user=request.user)

            is_crush_exists = models.Crush.objects.filter(
                my_user=request.user
            ).exists()

            token, token_max_age = self.__login(user=request.user)

            return token, token_max_age, is_crush_exists

    def __login(self, user):
        config = get_auth_conf()
        token_max_age = config.persistent_auth_token_max_age_in_sec
        token = self.__generate_token(user.id)

        client = self._get_client()
        value = dict(user_id=str(user.id))
        client.set(token, json.dumps(value), ex=token_max_age)

        return token, token_max_age

    @staticmethod
    def __generate_token(uid):
        return str(uid) + ':' + str(uuid.uuid4())
