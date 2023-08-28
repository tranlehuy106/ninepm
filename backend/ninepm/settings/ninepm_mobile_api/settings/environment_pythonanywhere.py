from ninepm.settings.common import (CACHES_DEFAULT, DB_NINE_VALUE)

DATABASES = dict(
    default={},
    ninepm=DB_NINE_VALUE,
)

NINEPM_DB = 'ninepm'
DATABASE_ROUTERS = [
    'ninepm.common.models.model_ninepm.database_routers.NinepmRouter',
]
CACHES = dict(default=CACHES_DEFAULT)
""" SECURITY WARNING: keep the secret key used in production secret! """
SECRET_KEY = 'template-secret-key'

ALLOWED_HOSTS = [
    'huy.ninepm.me',
]
""" AUTH SETTINGS """
AUTH_CONFIG = {
    'AUTH_HEADER_NAME': 'ninepm',
    'AUTH_TOKEN_STORAGE':
        {
            'ENGINE': 'redis',
            'HOST': '127.0.0.1',
            'PORT': 6379,
            'DB': 0,
        },
    'PERSISTENT_AUTH_TOKEN_MAX_AGE': 1209600,
    # 14 * 24 * 60 * 60 (14 days in sec)
    'AUTH_TOKEN_AUTO_EXTEND': True,
    'PERSISTENT_AUTH_TOKEN_AUTO_EXTEND_AFTER': 86400,
    # 1 * 24 * 60 * 60 (1 day in sec)
}

NINEPM_MOBILE_CONFIG = {
    'DEVICE_TOKEN_HEADER_NAME': 'ninepm-device-token'
}

""" DEBUG MODE """
DEBUG = True

REST_FRAMEWORK = {
    'DEFAULT_RENDERER_CLASSES':
        [
            'ninepm.app.ninepm_mobile_api.utils.renderers.JSONRenderer',
        ],
}

OTP_CONF = {
    # 'OTP_GENERATOR': 'ninepm.app.ninepm_mobile_api.modules.common.otp.PrettyOTPGenerator',
    'OTP_GENERATOR': 'ninepm.app.ninepm_mobile_api.modules.common.otp.UATOTPGenerator',
    'DEFAULT_OTP': '111111'
}

OTP_LENGTH = 6
OTP_LIFETIME_IN_SECONDS = 5 * 60
SEND_OTP_IN_SECONDS = 90

MAX_OTP_IS_RETRIED = 10
OTP_RETRY_MAX_AGE = 86400,
# 24 * 60 * 60 (1 days in sec)

""" SEND NOTIFICATION SETTINGS """
NOTIFICATION_CLIENT = dict(
    dummy=dict(
        BACKEND=
        'common.clients.notification.dummy.client.DummyNotificationClient',
    ),
    fcm=dict(
        BACKEND='common.clients.notification.fcm.client.FcmNotificationClient',
        CREDENTIALS=dict(
            type="service_account",
            project_id="ninepm-4f426",
            private_key_id="1286cafee3a972bd7f99f490ada322f50cad291b",
            private_key="-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC4qQG6pDligICI\nDI8T4ea2ISnY8+NkznsHolHoKnTOPzrPze5V0w+naww7yceuG5Ur4VX5O9dqU1Vt\n3CVsxPjj60hDwHTF24AYx+6rDV76b9T+pgiRUUIt0HNGeXw3gl1TnE6aEyCwfgb1\nRxv6/kVBvXoz0WSNdSQEFOIgJGL01XenBbH+a9ahKRz8DA+EIn5JtFeVdTugAiQD\nvzBniQTGEaOQ0Eq39MnP6giPBznAxEwQoGg35e3+6drGgtEnLWbg+N7aCZeYK2xC\ncE8L/7WjzTLhTpSZAKv15PwqCSnbScgprmKdTgqYNomciJINp9lLSw8mkfvpK9ZN\n+Og5zJ+BAgMBAAECggEADLgHWHWrRi+XqsdCq5nprC3IlhrmVLEsJDB398fE19ff\nEyUZ/2tULrHe29dgG4vm0Gjq5QnMIpSu06xQH5fJlNlF1vTQljgyMILE259GJXXC\nc++3s1qndkRfTEFd3uzpxLKFb3NV0xI7JHXLZZRR7N9CJYOMq3mgC2/sy032Suqy\n2u2wqpEXZ45lvpJpAYWJ5OfBF1fM9fsnNfdGfxq3+RWgoaFXRfjT5ziKqvBlkwKB\nHaX6H3VYPxn1MSBqPOLK00+mImGxJRM98uvrWFsqLh2CG1c4R2BZsuaEa/s743o7\nl3FGFxdxr2vUTmeKdwLWm0AqfSNDSEGfINRlINAxYQKBgQD63Vv7gmR83Q/DVyvu\nPumnZF1dpPmBV5aJLWnSdazQ2IP6OSE1M+5bDPUvZ5DVJPAxilF6VwjNrS4MOLko\nw+k9ZFm0UsK/kiknEZrHYVy7VFmj9JwwGpFXu4N/fYyq+XEJZ+IMfWSJ5HR+wJiw\nyBSZbPvQVHItOYMW7FppjVnF3QKBgQC8cLT3AjlfZoji8lYAm570eX4brYMVQxU4\njD1Lb1pFLgBZpZvAJU9CLsxcpJ+JgWVkzy21bL8y5UmvTO5UfjP1az2m9CyrZ2s+\nYEDQlUipQJxD5xBUd5f80ed68bHtF0NNzeK1J2yw+Nx8YlqtSrgFVgrdbaTUuZbc\ngYS/8Baf9QKBgQCkUEUlUdzb5Dek7P37SP3mBFkbMymxzFrvcu1zSlxtVsPrK2xS\n2rbusGgQKre0xEMHT9/aUBOWFC6rFqRAzUGCUq5m7CZfMC8ARgmpOl5w3Ojx+RAs\nedplKo8Q/H0cp9GgJYjsQV2O7DJZq3DXqdXEQJwXcphugtMYOqtlo43/iQKBgQCO\nAPUuazum+9LOC0bqIFvx6Zgx7Vip7iqQuYX7UceZ+GeFJvqvGq6WtkOE0P30llE9\nXa8ZWADhrs4PT48Olyg6mn0UUk9TP5UepVRSmxzthuX7eaXhsVoUyG2DRZ4KiAxN\nFojwcOxElNU62rdwfa0dQFDhup2LPOxF8UiDh77U/QKBgA70xuLoE0oHyNKgmS7D\n7xEt7uJf5OqZyIcImXbWW2VGtEGpavdPG4sk2Ow3Fu78yRmy96vCJNUtE4Xwmn6R\niAr+Z8tMionBlSbAq2wxVsjYC2E/p7gjMbXL28c+paPPttRfZOgkHQOo7D+h1tIa\nEJhYSkTgsaj5aiY70e1BAJ34\n-----END PRIVATE KEY-----\n",
            client_email="firebase-adminsdk-492ft@ninepm-4f426.iam.gserviceaccount.com",
            client_id="111879165313752362675",
            auth_uri="https://accounts.google.com/o/oauth2/auth",
            token_uri="https://oauth2.googleapis.com/token",
            auth_provider_x509_cert_url="https://www.googleapis.com/oauth2/v1/certs",
            client_x509_cert_url="https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-492ft%40ninepm-4f426.iam.gserviceaccount.com",
            universe_domain="googleapis.com",
        ),
        DEFAULT_CONFIG=dict(
            android=dict(
                channel_id="normal_channel",  # or default_channel
            ),
        )
    ),
)
NOTIFICATION_CLIENT_DEFAULT = 'fcm'
