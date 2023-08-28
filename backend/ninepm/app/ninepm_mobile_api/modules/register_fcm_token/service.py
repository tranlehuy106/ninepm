__all__ = ['ViewService']

from ninepm.app.ninepm_mobile_api.modules.common.base_service import \
    BaseViewService
from ninepm.common.models.model_ninepm import models


class ViewService(BaseViewService):

    def __init__(self) -> None:
        super().__init__()

    @staticmethod
    def register_fcm_token(
        device_token: str,
        fcm_token: str,
    ):
        try:
            models.FcmTokenMembership.objects.get(
                device_token=device_token,
                fcm_token=fcm_token,
            )
        except models.FcmTokenMembership.DoesNotExist:
            models.FcmTokenMembership.objects.create(
                device_token=device_token,
                fcm_token=fcm_token,
            )
