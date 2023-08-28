__all__ = [
    'OutputCrushSerializer',
    'OutputLoverSerializer',
]

from rest_framework import serializers

from ninepm.app.ninepm_mobile_api.base.serializers import AbstractSerializer


class OutputCrushSerializer(AbstractSerializer):
    phone_number_of_crush = serializers.CharField(required=True)
    start_at = serializers.DateTimeField(required=True)


class OutputLoverSerializer(AbstractSerializer):
    crush_user_id = serializers.IntegerField(required=True)
    phone_number_of_crush = serializers.CharField(required=True)
    start_at = serializers.DateTimeField(required=True)
