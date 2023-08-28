__all__ = [
    'View',
]

from rest_framework import status as http_status
from rest_framework.request import Request
from ninepm.app.ninepm_mobile_api.base.view import AbstractAuthenticatedView

from . import service


class View(AbstractAuthenticatedView):
    def __init__(self):
        super().__init__()
        self.service = service.ViewService()

    def get(self, request: Request, format=None):
        if request.user is None:
            return self._build_response(
                success=False,
                http_status=http_status.HTTP_401_UNAUTHORIZED
            )
        if request.user.is_anonymous:
            return self._build_response(
                success=False,
                http_status=http_status.HTTP_401_UNAUTHORIZED
            )

        try:
            self.service.update_fcm(
                user=request.user,
                device_token=self._request_client.device_token,
            )
        except Exception as e:
            print(e)
            pass

        return self._build_response(
            success=True,
        )
