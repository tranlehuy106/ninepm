__all__ = ['UATOTPGenerator']

from django.conf import settings

from .base_otp_generator import BaseOTPGenerator


class UATOTPGenerator(BaseOTPGenerator):
    @staticmethod
    def generate(otp_length: int) -> str:
        default_otp = UATOTPGenerator.get_default_otp()
        if default_otp is None:
            return '111111'
        return default_otp

    @staticmethod
    def get_default_otp():
        try:
            return settings.OTP_CONF['DEFAULT_OTP']
        except (AttributeError, KeyError) as e:
            return None
