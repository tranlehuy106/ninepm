__all__ = [
    'InputSerializer',
]

from rest_framework import serializers

from ninepm.app.ninepm_mobile_api.base.serializers import AbstractSerializer


class InputSerializer(AbstractSerializer):
    fcm_token = serializers.CharField(required=True)
