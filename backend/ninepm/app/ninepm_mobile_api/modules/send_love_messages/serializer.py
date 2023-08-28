__all__ = [
    'InputSerializer',
]

from rest_framework import serializers

from ninepm.app.ninepm_mobile_api.base.serializers import AbstractSerializer


class InputSerializer(AbstractSerializer):
    phone_number_of_crush = serializers.CharField(required=True)
    reminiscent_name = serializers.CharField(required=True)
