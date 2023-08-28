from django.urls import re_path as url
from .modules import healthcheck, login_status, login_request, \
    validate_login_otp, send_otp_again, send_love_messages, get_list_crush, \
    get_list_lover, register_fcm_token, get_fetch_data_chat, send_message, \
    seen_message

urlpatterns = [
    url(r'^health-check$', healthcheck.View.as_view()),
    url(r'^login-status$', login_status.View.as_view()),
    url(r'^login-request$', login_request.View.as_view()),
    url(r'^validate-login-otp$', validate_login_otp.View.as_view()),
    url(r'^send-otp-again$', send_otp_again.View.as_view()),
    url(r'^send-love-messages$', send_love_messages.View.as_view()),
    url(r'^get-list-crush$', get_list_crush.View.as_view()),
    url(r'^get-list-lover$', get_list_lover.View.as_view()),
    url(r'^register-fcm-token$', register_fcm_token.View.as_view()),
    url(r'^get-fetch-data-chat$', get_fetch_data_chat.View.as_view()),
    url(r'^send-message$', send_message.View.as_view()),
    url(r'^seen-message$', seen_message.View.as_view()),
]
