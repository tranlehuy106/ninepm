__all__ = ['PhoneNumberVerificationRequest']

from enum import auto

from django.db import models

from common.enum.constants import StringConstant
from .base.abstract_versioned_model import AbstractVersionedNineModel


class PhoneNumberVerificationRequest(AbstractVersionedNineModel):

    class VerificationStatus(StringConstant):
        VERIFIED = auto()
        NOT_VERIFIED = auto()

    class Status(StringConstant):
        NEW = auto()
        CLOSED = auto()

    class Result(StringConstant):
        SUCCESS = auto()
        FAILED = auto()

    user = models.ForeignKey(
        to='NinepmUser', db_constraint=False, on_delete=models.DO_NOTHING,
        related_name='user_in_phone_number_verification_request'
    )

    phone_number = models.CharField(max_length=20)

    token_key = models.CharField(max_length=255, unique=True)

    token_value = models.CharField(max_length=1024)

    verification_status = models.CharField(
        choices=VerificationStatus.choices(), max_length=30
    )

    status = models.CharField(
        choices=Status.choices(),
        max_length=30,
    )

    result = models.CharField(
        choices=Result.choices(), max_length=30, null=True
    )

    expired_at = models.DateTimeField(null=True)
