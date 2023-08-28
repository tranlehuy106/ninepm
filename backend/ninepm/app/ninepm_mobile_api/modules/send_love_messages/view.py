__all__ = [
    'View',
]

from enum import auto

from rest_framework.request import Request

from common.enum.constants import StringConstant
from ninepm.app.ninepm_mobile_api.base.view import AbstractAuthenticatedView

from . import service, serializer


class View(AbstractAuthenticatedView):
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
        phone_number_of_crush = valid_data.get('phone_number_of_crush')
        reminiscent_name = valid_data.get('reminiscent_name')

        try:
            self.service.send_love_messages(
                user=self._request_client.user,
                phone_number_of_crush=phone_number_of_crush,
                reminiscent_name=reminiscent_name,
            )
        except NotImplementedError as e:
            return self._build_response(
                success=False,
                response_code=self.ResponseCode.ERROR,
                messages=e.args[0],
            )

        return self._build_response(
            success=True,
            response_code=self.ResponseCode.SUCCESS,
        )
