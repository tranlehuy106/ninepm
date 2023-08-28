from dataclasses import dataclass


@dataclass(frozen=True)
class HealthCheckResponse:
    is_ok: bool
