__all__ = [
    "AbstractModel"
]

from django.db import (
    models,
)
import uuid
TEXT_ID_FIELD_MAX_LENGTH = 255


class AbstractModel(models.Model):
    class Meta:
        abstract = True

    text_id = models.CharField(unique=True, max_length=TEXT_ID_FIELD_MAX_LENGTH)

    db_log_created_at = models.DateTimeField(auto_now_add=True,
                                             verbose_name='DB log created at')
    db_log_updated_at = models.DateTimeField(auto_now=True,
                                             verbose_name='DB log updated at')

    def save(self, *args, **kwargs):
        if not self.text_id:
            self.text_id = self._generate_text_id()
        super().save(*args, **kwargs)

    """Can override"""
    def _generate_text_id(self):
        return uuid.uuid4().hex
