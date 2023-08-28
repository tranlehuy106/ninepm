from typing import Optional
from .abstract_view import AbstractNinepmMobileView
from ninepm.app.ninepm_mobile_api.dtos.request_client_info import \
    RequestClientInfo


class AbstractUnauthenticatedView(AbstractNinepmMobileView):
    authentication_classes = []
    permission_classes = []

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def initial(self, request, *args, **kwargs):
        super().initial(request, *args, **kwargs)
        self._request_client = RequestClientInfo(
            client_ip=self._get_client_ip(request),
            device_token=self._get_device_token(request),
            user=request.user
        )

    @property
    def request_client(self) -> Optional[RequestClientInfo]:
        return self._request_client
