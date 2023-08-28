__all__ = ['NinepmUser']

from django.contrib.auth.base_user import AbstractBaseUser
from django.db import models
from .base.abstract_versioned_model import AbstractVersionedNineModel


class NinepmUser(AbstractVersionedNineModel, AbstractBaseUser):
    phone_number = models.CharField(max_length=20, unique=True)

    USERNAME_FIELD = 'phone_number'
    REQUIRED_FIELDS = []
