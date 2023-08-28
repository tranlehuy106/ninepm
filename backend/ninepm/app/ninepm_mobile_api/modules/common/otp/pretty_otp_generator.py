__all__ = ['PrettyOTPGenerator']

import secrets

from .base_otp_generator import BaseOTPGenerator

OTP_MIN_LENGTH = 2


class PrettyOTPGenerator(BaseOTPGenerator):

    @staticmethod
    def generate(otp_length: int) -> str:
        if otp_length <= OTP_MIN_LENGTH:
            raise ValueError('OTP length is too short')
        allowed_chars = '0123456789'
        initial_pass_length = otp_length - OTP_MIN_LENGTH
        initial_pass = ''.join(
            secrets.choice(allowed_chars) for i in range(initial_pass_length))
        otp = initial_pass + ''.join(
            secrets.choice(initial_pass)
            for i in range(otp_length - initial_pass_length))
        return otp
