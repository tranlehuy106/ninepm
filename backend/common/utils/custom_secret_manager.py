import json
import logging
import os
import traceback
from json import JSONDecodeError

from django.core.exceptions import ImproperlyConfigured
from google.api_core.exceptions import GoogleAPIError
from google.cloud import secretmanager
from google.oauth2 import service_account

from common.utils.crypto.aes_cipher import AESCipher

DEFAULT_ENGINE = 'google_secret_manager'


class CustomSecretManager(object):
    def __init__(self, config=None, logger=None):
        if config is None:
            try:
                config_path = os.getenv('GOOGLE_APPLICATION_CREDENTIALS', None)
                key_file = open(config_path, "rb")
                config_bytes = key_file.read()
                config = json.loads(config_bytes.decode('utf-8'))
            except FileNotFoundError as e:
                logging.exception(traceback.print_exc())
                raise e
            except JSONDecodeError as e:
                logging.exception(traceback.print_exc())
                raise e

        # Get credentials
        credentials = service_account.Credentials.from_service_account_info(config)

        # Create the Secret Manager client.
        self.client = secretmanager.SecretManagerServiceClient(credentials=credentials)

    def get_secret_key(self, key_id, version='latest', project_id=None, output_decode=True):
        """
        Provide authentication credentials to your application code by setting the environment variable
        GOOGLE_APPLICATION_CREDENTIALS. Replace [PATH] with the file path of the JSON file that contains your service
        account key, and [FILE_NAME] with the filename. This variable only applies to your current shell session, so if you
        open a new session, set the variable again.
        :param key_id:
        :param version:
        :param project_id:
        :param output_decode: boolean
        :return: secret in string or bytes
        """

        assert isinstance(key_id, str)
        assert isinstance(version, int) or version == 'latest'
        assert isinstance(project_id, (str, type(None)))

        if project_id is None:
            project_id = os.getenv('GOOGLE_SM_PROJECT_ID')

        # Build secret version path.
        secret_version_path = self.client.secret_version_path(project=project_id, secret=key_id, secret_version=version)

        # Get secret version.
        try:
            response = self.client.access_secret_version(name=secret_version_path)
        except GoogleAPIError as e:
            logging.exception(e)
            raise e

        # TODO: Handle Exception

        # Return secret value
        if output_decode is True:
            return response.payload.data.decode('UTF-8')

        return response.payload.data


class SecretManagerClient(object):
    def __init__(self, prefix: str = None, engine: str = None, *args, **kwargs):
        assert isinstance(prefix, (str, type(None)))
        self.prefix = prefix
        self.engine_name = engine if engine is not None else DEFAULT_ENGINE
        if self.engine_name == 'google_secret_manager':
            assert 'encrypted_key' in kwargs
            assert 'secret' in kwargs
            encrypted_key = kwargs['encrypted_key']
            secret = kwargs['secret']
            (svc_acc_config, project_id) = get_google_secret_manager_config(encrypted_key=encrypted_key, secret=secret)
            self.engine = CustomSecretManager(config=svc_acc_config)
            self.project_id = project_id
        else:
            raise NotImplementedError("Engine %s not supported yet" % engine)

    def get_secret_key(self, key_id: str, using_prefix: bool = True, **kwargs):
        assert isinstance(key_id, str)
        assert isinstance(using_prefix, bool)

        if self.engine_name == 'google_secret_manager':
            version = kwargs['version'] if 'version' in kwargs else 'latest'
            key = "%s_%s" % (self.prefix, key_id) if using_prefix and self.prefix is not None else key_id
            output_decode = kwargs['output_decode'] if 'output_decode' in kwargs else True
            secret_key = self.engine.get_secret_key(
                key_id=key, project_id=self.project_id, version=version,
                output_decode=output_decode
                )
            return secret_key
        else:
            raise NotImplementedError("Engine %s not supported yet" % self.engine)

    def force_close_connection(self):
        if self.engine_name == 'google_secret_manager':
            if self.engine and self.engine.client \
                    and self.engine.client.transport:
                self.engine.client.transport.close()


def get_google_secret_manager_config(encrypted_key, secret):
    assert isinstance(encrypted_key, (str, bytes))
    assert isinstance(secret, (str, bytes))

    try:
        aes_cipher = AESCipher(secret)
        text_svc_acc_conf = aes_cipher.decrypt(encrypted_key)
        svc_acc_conf = json.loads(text_svc_acc_conf.decode('utf-8'))

        if 'project_id' not in svc_acc_conf:
            raise ImproperlyConfigured('service account must have project_id attribute')
        project_id = svc_acc_conf['project_id']

        return svc_acc_conf, project_id
    except json.JSONDecodeError as e:
        logging.exception(e)
        raise e
