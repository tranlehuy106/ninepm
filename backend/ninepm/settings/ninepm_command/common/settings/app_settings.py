import os

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

INSTALLED_APPS = [
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'ninepm.app.ninepm_command'
]

MIDDLEWARE = []

USE_TZ = True
