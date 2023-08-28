__all__ = [
    'OutputSerializer',
]

from rest_framework import serializers

from ninepm.app.ninepm_mobile_api.base.serializers import AbstractSerializer


class OutputSerializer(AbstractSerializer):
    crush_user_id = serializers.IntegerField(required=True, allow_null=True)
    phone_number_of_crush = serializers.CharField(required=True)
    message = serializers.CharField(required=True, allow_blank=True)
    status = serializers.CharField(required=True)
    start_at = serializers.DateTimeField(required=True)
