from dataclasses import dataclass
from typing import Optional


@dataclass
class RoadSegment:
    road_segment_id: Optional[int]
    length: float
    surface: str
    speed_limit: int
    lane_width: float
    lanes: int
    bike_lanes: bool = False
    sidewalks: bool = False
    grade: Optional[float] = None
    created_at: Optional[object] = None
    updated_at: Optional[object] = None

    @classmethod
    def from_row(cls, row: dict):
        return cls(**row)
