__all__ = [
    "Sha256WithRsa",
    "InvalidSignatureException",
]

from base64 import b64encode, b64decode

from Crypto.Hash import SHA256
from Crypto.PublicKey import RSA
from Crypto.Signature import PKCS1_v1_5, pkcs1_15

from common.utils.crypto.rsa_cipher import RSACipher


class InvalidSignatureException(Exception):
    pass


class Sha256WithRsa:
    @staticmethod
    def sign(*, data_bytes: bytes, private_key_bytes: bytes, passphrase_bytes: bytes = b'', is_base64=True) -> bytes:
        assert isinstance(data_bytes, bytes)
        assert isinstance(private_key_bytes, bytes)
        assert isinstance(passphrase_bytes, bytes)
        assert isinstance(is_base64, bool)

        digest = SHA256.new()
        digest.update(data_bytes)

        passphrase = passphrase_bytes if passphrase_bytes != b'' else None
        private_key = RSA.importKey(private_key_bytes, passphrase=passphrase)
        signer = PKCS1_v1_5.new(private_key)

        signature = signer.sign(digest)

        result = b64encode(signature) if is_base64 is True else signature
        return result

    @staticmethod
    def verify(
            *,
            data_bytes: bytes,
            signature_bytes: bytes,
            certificate_bytes: bytes = None,
            public_key_bytes: bytes = None,
            is_base64: bool = True
    ):
        if certificate_bytes is None and public_key_bytes is None:
            raise AssertionError("certificate_bytes or public_key_bytes must not be None")

        _public_key_bytes = public_key_bytes if public_key_bytes is not None \
            else RSACipher.get_public_key_from_certificate(certificate_bytes=certificate_bytes)

        _signature_bytes = b64decode(signature_bytes) if is_base64 is True else signature_bytes

        digest = SHA256.new()
        digest.update(data_bytes)

        rsa_key = RSA.importKey(extern_key=_public_key_bytes)
        rsa_verifier = pkcs1_15.new(rsa_key)

        try:
            rsa_verifier.verify(msg_hash=digest, signature=_signature_bytes)
        except ValueError:
            raise InvalidSignatureException()
