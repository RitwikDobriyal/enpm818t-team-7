from dataclasses import dataclass
from typing import Optional


@dataclass
class Sensor:
    sensor_id: Optional[int]
    type: str
    status: Optional[str] = None
    location_details: Optional[str] = None
    transmission_frequency: Optional[int] = None
    measured_parameter: Optional[str] = None
    road_segment_id: Optional[int] = None
    intersection_id: Optional[int] = None
    created_at: Optional[object] = None

    @classmethod
    def from_row(cls, row: dict):
        return cls(**row)
