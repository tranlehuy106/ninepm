__all__ = [
    'InputSerializer',
    'OutputSerializer',
]

from rest_framework import serializers

from ninepm.app.ninepm_mobile_api.base.serializers import AbstractSerializer


class InputSerializer(AbstractSerializer):
    receiver_id = serializers.IntegerField(required=True)


class OutputSerializer(AbstractSerializer):
    id = serializers.IntegerField(required=True)
    user_of_crush_id = serializers.IntegerField(required=True, allow_null=True)
    status = serializers.CharField(required=True)
    message = serializers.CharField(required=True)
    start_at = serializers.DateTimeField(required=True)
