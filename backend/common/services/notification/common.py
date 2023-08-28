__all__ = ["NotificationCommonService"]

from common.clients.notification.base import notification_client_provider
from common.clients.notification.client_interface import INotificationClient
from django.core.exceptions import ImproperlyConfigured
from django.conf import settings


class NotificationCommonService:

    def get_notification_client(
        self, notification_client: str = None
    ) -> INotificationClient:
        if notification_client is not None:
            try:
                return notification_client_provider[notification_client]
            except KeyError:
                raise ImproperlyConfigured(
                    "settings.NOTIFICATION_CLIENT[%s] missing" %
                    notification_client
                )
        default_client = self.__get_default_notification_settings()
        return notification_client_provider[default_client]

    @staticmethod
    def __get_default_notification_settings():
        try:
            return settings.NOTIFICATION_CLIENT_DEFAULT
        except KeyError:
            raise ImproperlyConfigured(
                "settings.NOTIFICATION_CLIENT_DEFAULT missing"
            )
