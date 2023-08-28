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
        token = valid_data.get('token')
        otp = valid_data.get('otp')

        try:
            token, token_max_age, is_crush_exists = \
                self.service.validate_login_otp(
                    token=token,
                    otp=otp,
                    device_token=self._request_client.device_token,
                )
        except NotImplementedError as e:
            return self._build_response(
                success=False,
                response_code=self.ResponseCode.ERROR,
                messages=e.args[0],
            )

        if token is None:
            return self._build_response(
                success=False,
                response_code=self.ResponseCode.ERROR,
                messages='Mã xác thực không đúng. Vui lòng thử lại.',
            )

        return self._build_response(
            success=True,
            response_code=self.ResponseCode.SUCCESS,
            data=dict(
                item=serializer.OutputSerializer(dict(token=token)).data,
                is_crush_exists=is_crush_exists,
            )
        )
