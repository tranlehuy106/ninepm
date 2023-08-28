from django.urls import re_path as url
from django.urls import include
from ninepm.app.ninepm_mobile_api import \
    urls as ninepm_mobile_api_patterns

urlpatterns = [
    url(r'^', include(ninepm_mobile_api_patterns)),
]
