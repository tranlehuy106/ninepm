__all__ = [
    "AbstractSerializer",
]

from rest_framework import serializers


class AbstractSerializer(serializers.Serializer):

    def update(self, instance, validated_data):
        pass

    def create(self, validated_data):
        pass
