from dataclasses import dataclass
from typing import Optional


@dataclass
class Intersection:
    intersection_id: Optional[int]
    latitude: float
    longitude: float
    capacity: int
    type: str
    elevation: Optional[float] = None
    created_at: Optional[object] = None
    updated_at: Optional[object] = None

    @classmethod
    def from_row(cls, row: dict):
        return cls(**row)
