__all__ = ["AbstractVersionedNineModel", "VersionMismatchError"]

from django.db import IntegrityError
from django.db import (
    models,
)
from django.db.models import F

from common.base.models.abstract_model import AbstractModel
from ninepm.common.models.model_ninepm import transaction


class VersionMismatchError(IntegrityError):
    pass


class AbstractVersionedNineModel(AbstractModel):

    class Meta:
        abstract = True

    version = models.IntegerField('version', default=1)

    def __init__(self, *args, **kwargs):
        self._check_version = True
        super().__init__(*args, **kwargs)

    def save(self, check_version: bool = True, *args, **kwargs):
        self._check_version = check_version
        super().save(*args, **kwargs)

    def _do_update(
        self, base_qs, using, pk_val, values, update_fields, forced_update
    ):
        """
        Try to update the model. Return True if the model was updated (if an
        update query was done and a matching row was found in the DB).
        """
        # extended model - try run normal do update. Version check/update will perform in parent model
        current_version = self.version
        if (update_fields is not None and (
                self._meta.get_field('version'), None,
                current_version) not in update_fields) \
                or (values is not None and (
                self._meta.get_field('version'), None,
                current_version) not in values):
            return super()._do_update(
                base_qs, using, pk_val, values, update_fields, forced_update
            )

        if self._check_version:
            result = self._do_update_check_version(
                base_qs, using, pk_val, values, update_fields, forced_update
            )
        else:
            result = self._do_update_not_check_version(
                base_qs, using, pk_val, values, update_fields, forced_update
            )

        return result

    def _do_update_check_version(
        self, base_qs, using, pk_val, values, update_fields, forced_update
    ):
        with transaction.atomic():
            current_version = self.version

            next_version = current_version + 1
            try:
                obj = base_qs.select_for_update().get(pk=pk_val)
            except self.__class__.DoesNotExist:
                return False

            if obj.version != current_version:
                raise VersionMismatchError("Version mismatch.")

            filtered = base_qs.select_for_update().filter(pk=pk_val)
            # filtered_with_version = base_qs.filter(pk=pk_val, version=current_version)
            if not values:
                # We can end up here when saving a model in inheritance chain where
                # update_fields doesn't target any field in current model. In that
                # case we just say the update succeeded. Another case ending up here
                # is a model with just PK - in that case check that the PK still
                # exists.
                return update_fields is not None or filtered.exists()
            current_version_field = (
                self._meta.get_field('version'), None, current_version
            )
            if current_version_field in values:
                values.remove(current_version_field)
            values.append(
                (self._meta.get_field('version'), None, next_version)
            )
            if self._meta.select_on_save and not forced_update:
                return (
                    filtered.exists() and
                    # It may happen that the object is deleted from the DB right after
                    # this check, causing the subsequent UPDATE to return zero matching
                    # rows. The same result can occur in some rare cases when the
                    # database returns zero despite the UPDATE being executed
                    # successfully (a row is matched and updated). In order to
                    # distinguish these two cases, the object's existence in the
                    # database is again checked for if the UPDATE query returns 0.
                    (filtered._update(values) > 0 or filtered.exists())
                )

            if filtered._update(values) > 0:
                self.version = next_version
                return True

            return False

    def _do_update_not_check_version(
        self, base_qs, using, pk_val, values, update_fields, forced_update
    ):
        """
        Try to update the model. Return True if the model was updated (if an
        update query was done and a matching row was found in the DB).
        """
        current_version = self.version

        filtered = base_qs.filter(pk=pk_val)
        if not values:
            # We can end up here when saving a model in inheritance chain where
            # update_fields doesn't target any field in current model. In that
            # case we just say the update succeeded. Another case ending up here
            # is a model with just PK - in that case check that the PK still
            # exists.
            return update_fields is not None or filtered.exists()
        current_version_field = self._meta.get_field(
            'version'), None, current_version
        if current_version_field in values:
            values.remove(current_version_field)
        values.append(
            (self._meta.get_field('version'), None, F('version') + 1)
        )
        if self._meta.select_on_save and not forced_update:
            return (
                filtered.exists() and
                # It may happen that the object is deleted from the DB right after
                # this check, causing the subsequent UPDATE to return zero matching
                # rows. The same result can occur in some rare cases when the
                # database returns zero despite the UPDATE being executed
                # successfully (a row is matched and updated). In order to
                # distinguish these two cases, the object's existence in the
                # database is again checked for if the UPDATE query returns 0.
                (filtered._update(values) > 0 or filtered.exists())
            )
        if filtered._update(values) > 0:
            self.refresh_from_db(fields=['version'])
            return True

        return False
