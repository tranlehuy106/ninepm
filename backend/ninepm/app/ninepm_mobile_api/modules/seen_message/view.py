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
        chat_messages_id = valid_data.get('chat_messages_id')

        try:
            self.service.seen(
                user=request.user,
                chat_messages_id=chat_messages_id,
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
