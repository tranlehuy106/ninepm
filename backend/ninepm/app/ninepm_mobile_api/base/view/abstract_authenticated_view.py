from typing import Optional

from .abstract_view import AbstractNinepmMobileView
from rest_framework.permissions import IsAuthenticated

from ninepm.app.ninepm_mobile_api.authenticator import Authenticator
from ninepm.app.ninepm_mobile_api.dtos.request_client_info import RequestClientInfo


class AbstractAuthenticatedView(AbstractNinepmMobileView):
    authentication_classes = [Authenticator]
    permission_classes = [IsAuthenticated]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def initial(self, request, *args, **kwargs):
        super().initial(request, *args, **kwargs)
        self._request_client = RequestClientInfo(
            user=request.user,
            client_ip=self._get_client_ip(request),
            device_token=self._get_device_token(request),
        )

    @property
    def request_client(self) -> Optional[RequestClientInfo]:
        return self._request_client
