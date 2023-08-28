__all__ = ["TaskProducerCommonService"]

from common.clients.task_producer.base import task_producer_client_provider
from common.clients.task_producer.client_interface import ITaskProducerClient
from django.core.exceptions import ImproperlyConfigured
from django.conf import settings


class TaskProducerCommonService:

    def get_task_producer_client(
        self, task_producer_client: str = None
    ) -> ITaskProducerClient:
        if task_producer_client is not None:
            try:
                return task_producer_client_provider[task_producer_client]
            except KeyError:
                raise ImproperlyConfigured(
                    "settings.TASK_PRODUCER_CLIENT[%s] missing" %
                    task_producer_client
                )
        default_client = self.__get_default_producer_settings()
        return task_producer_client_provider[default_client]

    @staticmethod
    def __get_default_producer_settings():
        try:
            return settings.TASK_PRODUCER_CLIENT_DEFAULT
        except KeyError:
            raise ImproperlyConfigured(
                "settings.TASK_PRODUCER_CLIENT_DEFAULT missing"
            )
