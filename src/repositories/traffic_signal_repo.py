from psycopg.rows import dict_row
from config.database import DatabaseConfig
from models.traffic_signal import TrafficSignal


class TrafficSignalRepository:
    def find_by_id(self, signal_id):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT signal_id, intersection_id, approach, type, timing_mode,
                           default_speed, status, created_at, updated_at
                    FROM traffic_signal
                    WHERE signal_id = %s
                    """,
                    (signal_id,)
                )
                row = cur.fetchone()
                return TrafficSignal.from_row(row) if row else None

    def find_all(self, limit=20, offset=0):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT signal_id, intersection_id, approach, type, timing_mode,
                           default_speed, status, created_at, updated_at
                    FROM traffic_signal
                    ORDER BY signal_id
                    LIMIT %s OFFSET %s
                    """,
                    (limit, offset)
                )
                return [TrafficSignal.from_row(row) for row in cur.fetchall()]
