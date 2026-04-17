from psycopg.rows import dict_row
from config.database import DatabaseConfig


class AnalyticsRepository:
    def get_high_incident_intersections(self, days=90, limit=10):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT
                        i.intersection_id,
                        i.latitude,
                        i.longitude,
                        COALESCE(tz.district, 'Unassigned') AS zone_name,
                        COUNT(DISTINCT inc.incident_id) AS incident_count,
                        COUNT(DISTINCT s.sensor_id) AS sensor_count
                    FROM intersection i
                    JOIN incident inc
                        ON inc.intersection_id = i.intersection_id
                    LEFT JOIN sensor s
                        ON s.intersection_id = i.intersection_id
                    LEFT JOIN road_intersection ri
                        ON ri.intersection_id = i.intersection_id
                    LEFT JOIN zone_assignment za
                        ON za.road_segment_id = ri.road_segment_id
                    LEFT JOIN traffic_zone tz
                        ON tz.zone_id = za.zone_id
                    WHERE inc.reported_time >= CURRENT_TIMESTAMP - (%s * INTERVAL '1 day')
                    GROUP BY i.intersection_id, i.latitude, i.longitude, tz.district
                    ORDER BY incident_count DESC, sensor_count DESC, i.intersection_id
                    LIMIT %s
                    """,
                    (days, limit)
                )
                return cur.fetchall()

    def get_system_metrics(self):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute("SELECT COUNT(*) AS total_intersections FROM intersection")
                total_intersections = cur.fetchone()["total_intersections"]

                cur.execute("SELECT COUNT(*) AS total_incidents FROM incident")
                total_incidents = cur.fetchone()["total_incidents"]

                cur.execute("SELECT COUNT(*) AS total_sensors FROM sensor")
                total_sensors = cur.fetchone()["total_sensors"]

                cur.execute(
                    """
                    SELECT COALESCE(AVG(sensor_count), 0) AS avg_sensors_per_intersection
                    FROM (
                        SELECT i.intersection_id, COUNT(s.sensor_id) AS sensor_count
                        FROM intersection i
                        LEFT JOIN sensor s ON s.intersection_id = i.intersection_id
                        GROUP BY i.intersection_id
                    ) sub
                    """
                )
                avg_sensors = cur.fetchone()["avg_sensors_per_intersection"]

                cur.execute(
                    """
                    SELECT COUNT(*) AS open_maintenance_tasks
                    FROM maintenance_task
                    WHERE status <> 'completed'
                    """
                )
                open_tasks = cur.fetchone()["open_maintenance_tasks"]

                return {
                    "total_intersections": total_intersections,
                    "total_incidents": total_incidents,
                    "total_sensors": total_sensors,
                    "avg_sensors_per_intersection": float(avg_sensors),
                    "open_maintenance_tasks": open_tasks,
                }

    def get_incident_counts_by_severity(self):
        with DatabaseConfig.get_connection() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(
                    """
                    SELECT severity, COUNT(*) AS incident_count
                    FROM incident
                    GROUP BY severity
                    ORDER BY incident_count DESC, severity
                    """
                )
                return cur.fetchall()
