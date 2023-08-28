__all__ = [
    "View",
]

from rest_framework.request import Request
from rest_framework import serializers
from ninepm.app.ninepm_mobile_api.base.serializers import AbstractSerializer
from ninepm.app.ninepm_mobile_api.base.view import AbstractUnauthenticatedView
from .service import ViewService


class View(AbstractUnauthenticatedView):

    class OutputSerializer(AbstractSerializer):
        is_ok = serializers.BooleanField(required=True)

    def __init__(self):
        super().__init__()
        self.service = ViewService()

    def get(self, request: Request):
        response = self.service.check()
        return self._build_response(
            success=True, data=self.OutputSerializer(response).data
        )
