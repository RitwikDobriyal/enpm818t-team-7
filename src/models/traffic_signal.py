from dataclasses import dataclass
from typing import Optional


@dataclass
class TrafficSignal:
    signal_id: Optional[int]
    intersection_id: int
    approach: str
    type: str
    timing_mode: str
    default_speed: Optional[int] = None
    status: Optional[str] = None
    created_at: Optional[object] = None
    updated_at: Optional[object] = None

    @classmethod
    def from_row(cls, row: dict):
        return cls(**row)
