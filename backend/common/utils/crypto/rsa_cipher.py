__all__ = [
    "RSACipher"
]

import base64

import OpenSSL
from Crypto.Cipher import PKCS1_v1_5
from Crypto.PublicKey import RSA


class LoadCertificateFailedException(Exception):
    pass


class RSACipher:
    @staticmethod
    def get_public_key_from_certificate(
            *,
            certificate_bytes: bytes,
            output_format=OpenSSL.crypto.FILETYPE_PEM
    ) -> bytes:
        try:
            certificate = OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_ASN1, certificate_bytes)
        except OpenSSL.crypto.Error:
            try:
                certificate = OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_PEM, certificate_bytes)
            except OpenSSL.crypto.Error:
                raise LoadCertificateFailedException()

        public_key_bytes = OpenSSL.crypto.dump_publickey(output_format, certificate.get_pubkey())
        return public_key_bytes

    @staticmethod
    def encrypt(*, data_bytes: bytes, public_key_bytes: bytes, ) -> bytes:
        rsa_key = RSA.importKey(public_key_bytes)
        rsa_cipher = PKCS1_v1_5.new(rsa_key)
        encrypted_data = rsa_cipher.encrypt(data_bytes)
        return encrypted_data

    @staticmethod
    def decrypt(*, encrypted_data_bytes: bytes, private_key_bytes: bytes, passphrase_bytes: bytes = b'') -> bytes:
        passphrase = passphrase_bytes if passphrase_bytes != b'' else None
        rsa_key = RSA.importKey(extern_key=private_key_bytes, passphrase=passphrase)
        rsa_cipher = PKCS1_v1_5.new(rsa_key)
        sentinel = b''
        data_bytes = rsa_cipher.decrypt(encrypted_data_bytes, sentinel, 0)
        return bytes(data_bytes)

    @staticmethod
    def encrypt_using_private_key(*, data_bytes: bytes, private_key: bytes) -> bytes:
        key = RSA.importKey(private_key)
        encryptor = PKCS1_v1_5.new(key)
        encrypted_msg = encryptor.encrypt(data_bytes)
        encoded_encrypted_msg = base64.b64encode(encrypted_msg)
        return encoded_encrypted_msg

    @staticmethod
    def decrypt_using_public_key(*, encrypted_data_bytes: bytes, public_key: bytes) -> bytes:
        rsa_key = RSA.importKey(public_key)
        rsa_cipher = PKCS1_v1_5.new(rsa_key)
        sentinel = b''
        data_bytes = rsa_cipher.decrypt(encrypted_data_bytes, sentinel, 0)
        return bytes(data_bytes)
