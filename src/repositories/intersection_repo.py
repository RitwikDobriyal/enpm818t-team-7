from psycopg.rows import dict_row
from config.database import DatabaseConfig
from models.intersection import Intersection


class IntersectionRepository:
    def find_by_id(self, intersection_id):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT intersection_id, latitude, longitude, capacity, type,
                           elevation, created_at, updated_at
                    FROM intersection
                    WHERE intersection_id = %s
                    """,
                    (intersection_id,)
                )
                row = cur.fetchone()
                return Intersection.from_row(row) if row else None

    def find_all(self, limit=20, offset=0):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT intersection_id, latitude, longitude, capacity, type,
                           elevation, created_at, updated_at
                    FROM intersection
                    ORDER BY intersection_id
                    LIMIT %s OFFSET %s
                    """,
                    (limit, offset)
                )
                return [Intersection.from_row(row) for row in cur.fetchall()]

    def create(self, entity: Intersection):
        with DatabaseConfig.get_connection() as conn:
            with conn.transaction():
                with conn.cursor(row_factory=dict_row) as cur:
                    cur.execute(
                        """
                        INSERT INTO intersection (latitude, longitude, capacity, type, elevation)
                        VALUES (%s, %s, %s, %s, %s)
                        RETURNING intersection_id, latitude, longitude, capacity, type,
                                  elevation, created_at, updated_at
                        """,
                        (
                            entity.latitude,
                            entity.longitude,
                            entity.capacity,
                            entity.type,
                            entity.elevation
                        )
                    )
                    return Intersection.from_row(cur.fetchone())

    def update(self, entity: Intersection):
        with DatabaseConfig.get_connection() as conn:
            with conn.transaction():
                with conn.cursor(row_factory=dict_row) as cur:
                    cur.execute(
                        """
                        UPDATE intersection
                        SET latitude = %s,
                            longitude = %s,
                            capacity = %s,
                            type = %s,
                            elevation = %s
                        WHERE intersection_id = %s
                        RETURNING intersection_id, latitude, longitude, capacity, type,
                                  elevation, created_at, updated_at
                        """,
                        (
                            entity.latitude,
                            entity.longitude,
                            entity.capacity,
                            entity.type,
                            entity.elevation,
                            entity.intersection_id
                        )
                    )
                    row = cur.fetchone()
                    return Intersection.from_row(row) if row else None

    def delete(self, intersection_id):
        with DatabaseConfig.get_connection() as conn:
            with conn.transaction():
                with conn.cursor() as cur:
                    cur.execute(
                        "DELETE FROM intersection WHERE intersection_id = %s",
                        (intersection_id,)
                    )
                    return cur.rowcount > 0

    def find_high_capacity(self, min_capacity):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT intersection_id, latitude, longitude, capacity, type,
                           elevation, created_at, updated_at
                    FROM intersection
                    WHERE capacity >= %s
                    ORDER BY capacity DESC, intersection_id
                    """,
                    (min_capacity,)
                )
                return [Intersection.from_row(row) for row in cur.fetchall()]
