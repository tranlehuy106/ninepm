__all__ = ['ChatMessage']

from enum import auto

from django.db import models

from common.enum.constants import StringConstant
from .base.abstract_versioned_model import AbstractVersionedNineModel


class ChatMessage(AbstractVersionedNineModel):

    class Status(StringConstant):
        SENT = auto()
        RECEIVED = auto()
        SEEN = auto()

    my_user = models.ForeignKey(
        to='NinepmUser', db_constraint=False, on_delete=models.DO_NOTHING,
        related_name='my_user_in_message'
    )

    user_of_crush = models.ForeignKey(
        to='NinepmUser', db_constraint=False, on_delete=models.DO_NOTHING,
        related_name='user_of_crush_in_message'
    )

    status = models.CharField(
        max_length=30, choices=Status.choices(), default=Status.SENT
    )

    message = models.CharField(max_length=1024)

    start_at = models.DateTimeField()
