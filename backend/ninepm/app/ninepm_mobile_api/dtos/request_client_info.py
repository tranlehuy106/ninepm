from ninepm.common.models.model_ninepm import models
from dataclasses import dataclass


@dataclass(frozen=True)
class RequestClientInfo:
    client_ip: str
    device_token: str
    user: models.NinepmUser = None

