from dataclasses import dataclass
from typing import Optional


@dataclass
class Incident:
    incident_id: Optional[int]
    type: str
    severity: str
    reported_time: Optional[object] = None
    resolved_time: Optional[object] = None
    verified_time: Optional[object] = None
    source: Optional[str] = None
    road_segment_id: Optional[int] = None
    intersection_id: Optional[int] = None

    @classmethod
    def from_row(cls, row: dict):
        return cls(**row)
