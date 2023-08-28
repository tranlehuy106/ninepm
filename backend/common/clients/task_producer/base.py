__all__ = ['task_producer_client_provider']

import logging
from django.core.exceptions import ImproperlyConfigured
from django.conf import settings
from django.utils.module_loading import import_string


def _create_client(alias: str):
    try:
        try:
            conf = settings.TASK_PRODUCER_CLIENT[alias]
        except KeyError:
            raise ImproperlyConfigured(
                "settings.TASK_PRODUCER_CLIENT[%s] missing" % alias
            )
        params = {**conf}
        backend = params.pop('BACKEND')
        backend_class = import_string(backend)
        return backend_class(params)
    except Exception as e:
        logging.error(e.__class__)
        logging.error(e)
        raise


class TaskProducerClientProvider:

    def __init__(self):
        self._clients = dict()
        try:
            config = settings.TASK_PRODUCER_CLIENT
        except AttributeError:
            raise ImproperlyConfigured("settings.TASK_PRODUCER_CLIENT missing")

        for key in config.keys():
            self._clients[key] = _create_client(key)

    def __getitem__(self, alias):
        return self._clients[alias]


task_producer_client_provider = TaskProducerClientProvider()
