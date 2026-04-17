from psycopg.rows import dict_row
from config.database import DatabaseConfig
from models.incident import Incident


class IncidentRepository:
    def find_by_id(self, incident_id):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT incident_id, type, severity, reported_time, resolved_time,
                           verified_time, source, road_segment_id, intersection_id
                    FROM incident
                    WHERE incident_id = %s
                    """,
                    (incident_id,)
                )
                row = cur.fetchone()
                return Incident.from_row(row) if row else None

    def find_all(self, limit=20, offset=0):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT incident_id, type, severity, reported_time, resolved_time,
                           verified_time, source, road_segment_id, intersection_id
                    FROM incident
                    ORDER BY incident_id
                    LIMIT %s OFFSET %s
                    """,
                    (limit, offset)
                )
                return [Incident.from_row(row) for row in cur.fetchall()]

    def create(self, entity: Incident):
        with DatabaseConfig.get_connection() as conn:
            with conn.transaction():
                with conn.cursor(row_factory=dict_row) as cur:
                    cur.execute(
                        """
                        INSERT INTO incident (
                            type, severity, reported_time, resolved_time,
                            verified_time, source, road_segment_id, intersection_id
                        )
                        VALUES (%s, %s, COALESCE(%s, CURRENT_TIMESTAMP), %s, %s, %s, %s, %s)
                        RETURNING incident_id, type, severity, reported_time, resolved_time,
                                  verified_time, source, road_segment_id, intersection_id
                        """,
                        (
                            entity.type,
                            entity.severity,
                            entity.reported_time,
                            entity.resolved_time,
                            entity.verified_time,
                            entity.source,
                            entity.road_segment_id,
                            entity.intersection_id
                        )
                    )
                    return Incident.from_row(cur.fetchone())

    def update(self, entity: Incident):
        with DatabaseConfig.get_connection() as conn:
            with conn.transaction():
                with conn.cursor(row_factory=dict_row) as cur:
                    cur.execute(
                        """
                        UPDATE incident
                        SET type = %s,
                            severity = %s,
                            reported_time = %s,
                            resolved_time = %s,
                            verified_time = %s,
                            source = %s,
                            road_segment_id = %s,
                            intersection_id = %s
                        WHERE incident_id = %s
                        RETURNING incident_id, type, severity, reported_time, resolved_time,
                                  verified_time, source, road_segment_id, intersection_id
                        """,
                        (
                            entity.type,
                            entity.severity,
                            entity.reported_time,
                            entity.resolved_time,
                            entity.verified_time,
                            entity.source,
                            entity.road_segment_id,
                            entity.intersection_id,
                            entity.incident_id
                        )
                    )
                    row = cur.fetchone()
                    return Incident.from_row(row) if row else None

    def delete(self, incident_id):
        with DatabaseConfig.get_connection() as conn:
            with conn.transaction():
                with conn.cursor() as cur:
                    cur.execute(
                        "DELETE FROM incident WHERE incident_id = %s",
                        (incident_id,)
                    )
                    return cur.rowcount > 0

    def find_by_severity(self, severity):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT incident_id, type, severity, reported_time, resolved_time,
                           verified_time, source, road_segment_id, intersection_id
                    FROM incident
                    WHERE severity = %s
                    ORDER BY reported_time DESC
                    """,
                    (severity,)
                )
                return [Incident.from_row(row) for row in cur.fetchall()]
