__all__ = ['Crush']

from enum import auto

from django.db import models

from common.enum.constants import StringConstant
from .base.abstract_versioned_model import AbstractVersionedNineModel


class Crush(AbstractVersionedNineModel):
    class Status(StringConstant):
        NEW = auto()
        MATCHED = auto()
        CONNECTING = auto()
        COMPLETED = auto()

    my_user = models.ForeignKey(
        to='NinepmUser', db_constraint=False, on_delete=models.DO_NOTHING,
        related_name='my_user_in_crush'
    )

    my_phone_number = models.CharField(max_length=20)
    phone_number_of_crush = models.CharField(max_length=20)

    crush_user = models.ForeignKey(
        to='NinepmUser', db_constraint=False, on_delete=models.DO_NOTHING,
        related_name='crush_user_in_crush', null=True,
    )

    reminiscent_name = models.CharField(max_length=255)

    status = models.CharField(
        max_length=30, choices=Status.choices(), default=Status.NEW
    )

    start_at = models.DateTimeField()

    matched_at = models.DateTimeField(null=True)

    completed_at = models.DateTimeField(null=True)
