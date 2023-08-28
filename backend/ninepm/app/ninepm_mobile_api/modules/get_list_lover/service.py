__all__ = ['ViewService']
from django.db.models import Q

from ninepm.app.ninepm_mobile_api.modules.common.base_service import \
    BaseViewService
from ninepm.common.models.model_ninepm import models


class ViewService(BaseViewService):

    def __init__(self) -> None:
        super().__init__()

    @staticmethod
    def get_list_lover(
        user: models.NinepmUser,
    ):
        lovers = models.Crush.objects.filter(
            my_user=user,
            status__in=[
                models.Crush.Status.CONNECTING,
                models.Crush.Status.COMPLETED,
            ],
        )

        items = []

        for lover in lovers:
            item = dict(
                crush_user_id=None if lover.crush_user is None else lover.crush_user.id,
                phone_number_of_crush=lover.phone_number_of_crush,
                message='',
                status=models.ChatMessage.Status.SEEN,
                start_at=lover.start_at,
            )

            chat_message = models.ChatMessage.objects.filter(
                Q(my_user=user) | Q(my_user=lover.crush_user),
                Q(user_of_crush=user) | Q(user_of_crush=lover.crush_user)
            ).last()

            if chat_message is not None:
                if chat_message.my_user != user:
                    item['status'] = chat_message.status

                item['message'] = chat_message.message
                item['start_at'] = chat_message.start_at

            items.append(item)

        return items
