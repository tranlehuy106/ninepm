# __all__ = ['BaseViewService']

import importlib

from django.conf import settings
from django.core.exceptions import ImproperlyConfigured

from common.clients.redis import RedisClientGenerator
from ninepm.app.ninepm_mobile_api.base.services.abstract_api_service import \
    AbstractApiService
from ninepm.app.ninepm_mobile_api.utils.conf import get_auth_token_storage_conf


def get_otp_generator():
    try:
        otp_generator_conf = settings.OTP_CONF['OTP_GENERATOR']
    except AttributeError:
        raise ImproperlyConfigured("settings.OTP_CONF missing")
    except KeyError:
        raise ImproperlyConfigured("settings.OTP_CONF['OTP_GENERATOR'] missing")

    otp_generator_module_path, otp_generator_class_name = otp_generator_conf.rsplit(
        ".", 1)
    otp_generator_module = importlib.import_module(otp_generator_module_path)
    otp_generator_class = getattr(otp_generator_module,
                                  otp_generator_class_name)
    return otp_generator_class()


class BaseViewService(AbstractApiService):

    def __init__(self) -> None:
        super().__init__()
        self._otp_generator = get_otp_generator()

    @staticmethod
    def _get_client():
        auth_token_storage = get_auth_token_storage_conf()

        if auth_token_storage.engine == 'redis':
            return RedisClientGenerator.get_client(auth_token_storage.__dict__)

        raise NotImplementedError('Sai cấu hình')
