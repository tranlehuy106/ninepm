__all__ = ['ViewService']

from ninepm.app.ninepm_mobile_api.modules.common.base_service import \
    BaseViewService
from ninepm.common.models.model_ninepm import models


class ViewService(BaseViewService):

    def __init__(self) -> None:
        super().__init__()

    @staticmethod
    def update_fcm(
        user: models.NinepmUser,
        device_token: str,
    ):
        models.FcmTokenMembership.objects.filter(
            device_token=device_token,
        ).update(user=user)
