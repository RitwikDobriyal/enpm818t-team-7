from psycopg.rows import dict_row
from config.database import DatabaseConfig
from models.sensor import Sensor


class SensorRepository:
    def find_by_id(self, sensor_id):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT sensor_id, type, status, location_details,
                           transmission_frequency, measured_parameter,
                           road_segment_id, intersection_id, created_at
                    FROM sensor
                    WHERE sensor_id = %s
                    """,
                    (sensor_id,)
                )
                row = cur.fetchone()
                return Sensor.from_row(row) if row else None

    def find_all(self, limit=20, offset=0):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT sensor_id, type, status, location_details,
                           transmission_frequency, measured_parameter,
                           road_segment_id, intersection_id, created_at
                    FROM sensor
                    ORDER BY sensor_id
                    LIMIT %s OFFSET %s
                    """,
                    (limit, offset)
                )
                return [Sensor.from_row(row) for row in cur.fetchall()]

    def create(self, entity: Sensor):
        with DatabaseConfig.get_connection() as conn:
            with conn.transaction():
                with conn.cursor(row_factory=dict_row) as cur:
                    cur.execute(
                        """
                        INSERT INTO sensor (
                            type, status, location_details, transmission_frequency,
                            measured_parameter, road_segment_id, intersection_id
                        )
                        VALUES (%s, %s, %s, %s, %s, %s, %s)
                        RETURNING sensor_id, type, status, location_details,
                                  transmission_frequency, measured_parameter,
                                  road_segment_id, intersection_id, created_at
                        """,
                        (
                            entity.type,
                            entity.status,
                            entity.location_details,
                            entity.transmission_frequency,
                            entity.measured_parameter,
                            entity.road_segment_id,
                            entity.intersection_id
                        )
                    )
                    return Sensor.from_row(cur.fetchone())

    def update(self, entity: Sensor):
        with DatabaseConfig.get_connection() as conn:
            with conn.transaction():
                with conn.cursor(row_factory=dict_row) as cur:
                    cur.execute(
                        """
                        UPDATE sensor
                        SET type = %s,
                            status = %s,
                            location_details = %s,
                            transmission_frequency = %s,
                            measured_parameter = %s,
                            road_segment_id = %s,
                            intersection_id = %s
                        WHERE sensor_id = %s
                        RETURNING sensor_id, type, status, location_details,
                                  transmission_frequency, measured_parameter,
                                  road_segment_id, intersection_id, created_at
                        """,
                        (
                            entity.type,
                            entity.status,
                            entity.location_details,
                            entity.transmission_frequency,
                            entity.measured_parameter,
                            entity.road_segment_id,
                            entity.intersection_id,
                            entity.sensor_id
                        )
                    )
                    row = cur.fetchone()
                    return Sensor.from_row(row) if row else None

    def delete(self, sensor_id):
        with DatabaseConfig.get_connection() as conn:
            with conn.transaction():
                with conn.cursor() as cur:
                    cur.execute(
                        "DELETE FROM sensor WHERE sensor_id = %s",
                        (sensor_id,)
                    )
                    return cur.rowcount > 0

    def find_by_intersection(self, intersection_id):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT sensor_id, type, status, location_details,
                           transmission_frequency, measured_parameter,
                           road_segment_id, intersection_id, created_at
                    FROM sensor
                    WHERE intersection_id = %s
                    ORDER BY sensor_id
                    """,
                    (intersection_id,)
                )
                return [Sensor.from_row(row) for row in cur.fetchall()]
