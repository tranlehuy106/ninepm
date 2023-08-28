__all__ = ['ViewService']

import threading

from django.db.models import Q

from common.services.notification.common import NotificationCommonService
from ninepm.app.ninepm_mobile_api.modules.common.base_service import \
    BaseViewService
from ninepm.common.models.model_ninepm import models


class ViewService(BaseViewService):

    def __init__(self) -> None:
        super().__init__()
        self.client = NotificationCommonService().get_notification_client()

    def background_task(self, chat_messages, user_of_crush, user):
        chat_messages.filter(
            my_user=user_of_crush,
            user_of_crush=user,
        ).update(status=models.ChatMessage.Status.SEEN)

        fcm_tokens = list(models.FcmTokenMembership.objects.filter(
            user=user_of_crush
        ).values_list('fcm_token', flat=True))

        self.client.send_notification(
            tokens=fcm_tokens,
            data=dict(
                type='seen',
            ),
        )

    def get_fetch_data_chat(
        self,
        user: models.NinepmUser,
        receiver_id: int,
    ):
        user_of_crush = models.NinepmUser.objects.get(id=receiver_id)

        chat_messages = models.ChatMessage.objects.filter(
            Q(my_user=user) | Q(my_user=user_of_crush),
            Q(user_of_crush=user) | Q(user_of_crush=user_of_crush),
        )

        my_thread = threading.Thread(
            target=self.background_task,
            args=[chat_messages, user_of_crush, user])
        my_thread.start()

        return chat_messages
