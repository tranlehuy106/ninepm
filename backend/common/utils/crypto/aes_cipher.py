__all__ = [
    "AESCipher"
]

import base64
import hashlib
from Crypto import Random
from Crypto.Cipher import AES


class AESCipher(object):
    def __init__(self, key, mode=AES.MODE_CBC, block_size=AES.block_size, encrypt_key=True):
        assert isinstance(key, (str, bytes))
        if isinstance(key, str):
            key = key.encode()

        self.bs = block_size
        self.mode = mode
        if encrypt_key:
            self.key = hashlib.sha256(key).digest()
        else:
            self.key = key

    def encrypt(self, raw, base64encode=True):
        assert isinstance(raw, (str, bytes))
        if isinstance(raw, str):
            raw = raw.encode()

        raw = self._pad(raw)

        if self.mode == AES.MODE_CBC:
            iv = Random.new().read(self.bs)
            cipher = AES.new(self.key, self.mode, iv)
            return base64.b64encode(iv + cipher.encrypt(raw))
        elif self.mode == AES.MODE_ECB:
            cipher = AES.new(self.key, self.mode)
            if base64encode:
                return base64.b64encode(cipher.encrypt(raw))
            else:
                return cipher.encrypt(raw)
        else:
            raise NotImplementedError("mode %s not supported" % self.mode)

    def decrypt(self, enc, base64decode=True):
        assert isinstance(enc, (str, bytes))

        if isinstance(enc, str):
            enc = enc.encode()

        if base64decode:
            enc = base64.b64decode(enc)

        if self.mode == AES.MODE_CBC:
            iv = enc[:self.bs]
            cipher = AES.new(self.key, self.mode, iv)
            padded_data = cipher.decrypt(enc[self.bs:])
            return self._unpad(padded_data)
        elif self.mode == AES.MODE_ECB:
            aes_cipher = AES.new(self.key, self.mode)
            padded_data = aes_cipher.decrypt(enc)
            return self._unpad(padded_data)

    def _pad(self, s):
        return s + (self.bs - len(s) % self.bs) * chr(self.bs - len(s) % self.bs).encode()

    @staticmethod
    def _unpad(s):
        return s[:-ord(s[len(s) - 1:])]
