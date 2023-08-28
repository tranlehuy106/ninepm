import os

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

INSTALLED_APPS = [
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'ninepm.common.models.model_ninepm',
    'ninepm.app.ninepm_mobile_api'
]

ROOT_URLCONF = 'ninepm.settings.ninepm_mobile_api.urls'

MIDDLEWARE = []

AUTH_USER_MODEL = 'model_ninepm.NinepmUser'

USE_TZ = True
