__all__ = [
    'InputSerializer',
]

from rest_framework import serializers

from ninepm.app.ninepm_mobile_api.base.serializers import AbstractSerializer


class InputSerializer(AbstractSerializer):
    receiver_id = serializers.IntegerField(required=True)
    message = serializers.CharField(required=True)
