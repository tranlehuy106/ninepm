__all__ = [
    'InputSerializer',
    'OutputSerializer',
]

from rest_framework import serializers

from ninepm.app.ninepm_mobile_api.base.serializers import AbstractSerializer


class InputSerializer(AbstractSerializer):
    token = serializers.CharField(required=True)
    otp = serializers.CharField(required=True)


class OutputSerializer(AbstractSerializer):
    token = serializers.CharField(required=True)
