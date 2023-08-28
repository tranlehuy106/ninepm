__all__ = ["FcmNotificationClient"]

from django.core.exceptions import ImproperlyConfigured
from typing import List, Optional
import firebase_admin
import logging
from firebase_admin import messaging
from firebase_admin.messaging import (
    MulticastMessage,
    Notification,
    AndroidNotification,
    AndroidConfig,
    Aps,
    APNSConfig,
    APNSPayload
)
from firebase_admin import credentials

from common.clients.notification.client_interface import INotificationClient


class FcmNotificationClient(INotificationClient):

    def __init__(self, config):
        super().__init__()
        self.credential_config = self.__get_credentials(config=config)
        self.default_sound = self.__get_default_sound(config=config)
        self.default_channel_id = self.__get_default_channel_id(config=config)
        self.android_click_action = 'FLUTTER_NOTIFICATION_CLICK'

    def send_notification(
        self,
        tokens: List,
        title: str = None,
        body: str = None,
        image: str = None,
        data: dict = None,
        sound: str = None,
        channel_id: str = None,
        pay_load: MulticastMessage = None
    ):
        try:
            firebase_admin.get_app()
        except ValueError:
            credential = credentials.Certificate(self.credential_config)
            firebase_admin.initialize_app(credential=credential)

            firebase_admin.get_app()

        if pay_load is not None:
            message = pay_load
        else:
            message = self._create_multicast_message(
                tokens=tokens,
                title=title,
                body=body,
                image=image,
                data=data,
                sound=sound,
                channel_id=channel_id
            )

        if message.apns and message.apns.payload and message.apns.payload.aps:
            logging.debug(message.apns.payload.aps.__dict__)

        response = messaging.send_multicast(message)

        if response:
            logging.debug(response.__dict__)

    def _create_multicast_message(
        self,
        tokens: List,
        title: str = None,
        body: str = None,
        image: str = None,
        data: dict = None,
        sound: str = None,
        channel_id: str = None,
    ):
        message = MulticastMessage(tokens=tokens)

        if title is not None or body is not None or image is not None:
            notification = Notification(title=title, body=body, image=image)
            message.notification = notification

        if data is not None:
            message.data = data

        android = self.__android_config(channel_id=channel_id)
        if android is not None:
            message.android = android

        apns = self.__ios_config(sound=sound)
        if apns is not None:
            message.apns = apns

        return message

    def __android_config(self,
                         channel_id: str = None) -> Optional[AndroidConfig]:
        if channel_id is None:
            channel_id = self.default_channel_id

        android = None
        android_notification = None

        if channel_id is not None:
            android_notification = AndroidNotification(
                click_action=self.android_click_action, channel_id=channel_id
            )

        if android_notification is not None:
            android = AndroidConfig(notification=android_notification)

        return android

    def __ios_config(self, sound: str = None) -> Optional[APNSPayload]:
        if sound is None:
            sound = self.default_sound

        apns = None
        apns_payload = None
        apns_payload_aps = None
        if sound is not None:
            apns_payload_aps = Aps(sound=sound)

        if apns_payload_aps is not None:
            apns_payload = APNSPayload(aps=apns_payload_aps)

        if apns_payload is not None:
            apns = APNSConfig(payload=apns_payload)
        return apns

    def __get_credentials(self, config):
        try:
            return config['CREDENTIALS']
        except KeyError as e:
            logging.error(e)
            raise ImproperlyConfigured("self.config['CREDENTIALS'] missing")

    def __get_default_channel_id(self, config):
        try:
            return config['DEFAULT_CONFIG']['android']['channel_id']
        except KeyError as e:
            logging.debug(e)
            return None

    def __get_default_sound(self, config):
        try:
            return config['DEFAULT_CONFIG']['apns']['sound']
        except KeyError as e:
            logging.debug(e)
            return None
