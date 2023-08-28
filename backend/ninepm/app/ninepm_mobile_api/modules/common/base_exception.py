from payment_gateway.app.pgw_merchant_web_api.base.services.permission.exception import *


class NoPermissionException(Exception):
    pass


class MerchantNotFoundException(Exception):
    pass


class OrderNotFoundException(Exception):
    pass
