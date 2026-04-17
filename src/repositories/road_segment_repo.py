from psycopg.rows import dict_row
from config.database import DatabaseConfig
from models.road_segment import RoadSegment


class RoadSegmentRepository:
    def find_by_id(self, road_segment_id):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT road_segment_id, length, surface, speed_limit, lane_width,
                           lanes, bike_lanes, sidewalks, grade, created_at, updated_at
                    FROM road_segment
                    WHERE road_segment_id = %s
                    """,
                    (road_segment_id,)
                )
                row = cur.fetchone()
                return RoadSegment.from_row(row) if row else None

    def find_all(self, limit=20, offset=0):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT road_segment_id, length, surface, speed_limit, lane_width,
                           lanes, bike_lanes, sidewalks, grade, created_at, updated_at
                    FROM road_segment
                    ORDER BY road_segment_id
                    LIMIT %s OFFSET %s
                    """,
                    (limit, offset)
                )
                return [RoadSegment.from_row(row) for row in cur.fetchall()]
