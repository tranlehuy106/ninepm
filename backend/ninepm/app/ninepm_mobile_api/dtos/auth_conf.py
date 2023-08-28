from dataclasses import dataclass


@dataclass(frozen=True)
class AuthConfig:
    auth_header_name: str
    persistent_auth_token_max_age_in_sec: int
    auto_extend_auth_token: bool
    auto_extend_persistent_auth_token_interval_in_sec: int


@dataclass(frozen=True)
class AuthTokenStorageConfig:
    engine: str
    host: str
    port: str
    password: str
    db: str
