__all__ = ['ViewService']

from ninepm.app.ninepm_mobile_api.modules.common.base_service import \
    BaseViewService
from ninepm.common.models.model_ninepm import models


class ViewService(BaseViewService):

    def __init__(self) -> None:
        super().__init__()

    @staticmethod
    def seen(
        user: models.NinepmUser,
        chat_messages_id: int,
    ):
        models.ChatMessage.objects.filter(
            id=chat_messages_id,
            user_of_crush=user,
        ).update(status=models.ChatMessage.Status.SEEN)
