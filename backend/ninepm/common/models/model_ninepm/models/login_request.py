__all__ = [
    'LoginRequest',
]

from enum import auto

from django.db import models

from common.enum.constants import StringConstant
from .base.abstract_versioned_model import AbstractVersionedNineModel


class LoginRequest(AbstractVersionedNineModel):
    class Status(StringConstant):
        NEW = auto()
        CLOSED = auto()

    class Result(StringConstant):
        SUCCESS = auto()
        FAILED = auto()

    user = models.ForeignKey(
        to='NinepmUser', db_constraint=False, on_delete=models.DO_NOTHING,
        related_name='user_in_login_request'
    )

    token = models.CharField(max_length=255, unique=True)

    token_value = models.CharField(max_length=1024)

    retry_number = models.IntegerField(default=0)

    status = models.CharField(
        choices=Status.choices(),
        max_length=30,
    )

    result = models.CharField(
        choices=Result.choices(),
        max_length=30,
        null=True
    )

    otp_expired_at = models.DateTimeField()

    send_otp_at = models.DateTimeField()
