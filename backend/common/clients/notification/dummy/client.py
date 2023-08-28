from common.clients.notification.client_interface import INotificationClient


class DummyNotificationClient(INotificationClient):

    def __init__(self, config):
        super().__init__()

    def send_notification(
        self,
        tokens,
        title=None,
        body=None,
        image=None,
        data=None,
        sound=None,
        channel_id=None,
        pay_load=None
    ):
        return
