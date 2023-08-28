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

    def get(self, request: Request, format=None):
        try:
            crushes, lovers = self.service.get_list_crush(
                user=self._request_client.user,
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
            data=dict(
                crushes=[
                    serializer.OutputCrushSerializer(crush).data for crush in
                    crushes
                ],
                lovers=[
                    serializer.OutputLoverSerializer(lover).data for lover in
                    lovers
                ]
            ),
        )
