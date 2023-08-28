__all__ = ['FcmTokenMembership']

from django.contrib.auth.base_user import AbstractBaseUser
from django.db import models
from .base.abstract_versioned_model import AbstractVersionedNineModel


class FcmTokenMembership(AbstractVersionedNineModel):
    class Meta:
        unique_together = [
            ('device_token', 'fcm_token'),
        ]

    user = models.ForeignKey(
        to='NinepmUser', db_constraint=False, on_delete=models.DO_NOTHING,
        related_name='user_in_fcm_token_membership',
        null=True,
    )

    device_token = models.CharField(max_length=255)

    fcm_token = models.CharField(max_length=255)
