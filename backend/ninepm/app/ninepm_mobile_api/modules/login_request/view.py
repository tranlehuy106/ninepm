__all__ = [
    'View',
]

from enum import auto

from rest_framework.request import Request

from common.enum.constants import StringConstant
from ninepm.app.ninepm_mobile_api.base.view import AbstractUnauthenticatedView

from . import service, serializer


class View(AbstractUnauthenticatedView):
    class ResponseCode(StringConstant):
        SUCCESS = auto()
        ERROR = auto()
        INVALID_PARAMS = auto()

    def __init__(self):
        super().__init__()
        self.service = service.ViewService()

    def post(self, request: Request, format=None):
        input_serializer = serializer.InputSerializer(data=request.data)
        if input_serializer.is_valid() is not True:
            return self._build_response(
                success=False,
                response_code=self.ResponseCode.INVALID_PARAMS,
                errors=input_serializer.errors,
            )
        valid_data = input_serializer.validated_data
        phone_number = valid_data.get('phone_number')

        try:
            token, otp = self.service.login_request(
                phone_number=phone_number,
            )
        except Exception as e:
            print(e)
            return self._build_response(
                success=False,
                response_code=self.ResponseCode.ERROR,
                messages='Có lỗi xảy ra. Vui lòng thử lại sau.',
            )

        try:
            self.service.send_otp(
                phone_number=phone_number,
                device_token=self._request_client.device_token,
            )
        except Exception as e:
            print(e)
            pass

        return self._build_response(
            success=True,
            response_code=self.ResponseCode.SUCCESS,
            data=serializer.OutputSerializer(dict(
                token=token,
                otp_length=len(otp),
            )).data
        )
