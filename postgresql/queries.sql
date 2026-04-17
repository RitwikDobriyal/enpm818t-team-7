-- =========================
-- Categories: 3 Multi-Table JOINs, 2 Aggregate Functions, 1 Subquery
-- =========================

-- =========================
-- Category 1: Multi-Table JOINs
-- =========================

-- Query #1: Maintenance Dispatch Report
-- Business Question: Which completed maintenance tasks were handled by which crew supervisors, and what type of intersections were they working on?
-- Complexity Features: 4-Table INNER JOIN
-- Tables Used: maintenance_task, maintenance_crew, intersection, sensor

SELECT 
    mt.task_id, 
    mc.specialization, 
    mc.supervisor, 
    s.type AS sensor_type, 
    i.intersection_id, 
    i.type AS intersection_type
FROM maintenance_task mt
JOIN maintenance_crew mc ON mt.crew_id = mc.crew_id
JOIN sensor s ON mt.sensor_id = s.sensor_id
JOIN intersection i ON s.intersection_id = i.intersection_id
WHERE mt.status = 'completed'
ORDER BY mt.completed_date DESC;

-- Expected Output: task_id (int), specialization (varchar), supervisor (varchar), sensor_type (enum), intersection_id (int), intersection_type (enum)
-- Sample Results: 
-- 102 | electrical | Supervisor 3  | radar          | 14 | signalized
-- 87  | civil      | Supervisor 8  | camera         | 42 | roundabout
-- 45  | software   | Supervisor 15 | inductive_loop | 8  | signalized

-- Query #2: Signal Hazard Report
-- Business Question: Which traffic signals are located at intersections that have recently had 'critical' or 'major' incidents?
-- Complexity Features: 3-Table INNER JOIN, DISTINCT filtering
-- Tables Used: intersection, incident, traffic_signal

SELECT DISTINCT
    ts.signal_id,
    ts.approach,
    ts.status AS signal_status,
    inc.type AS incident_type,
    inc.reported_time
FROM traffic_signal ts
JOIN intersection i ON ts.intersection_id = i.intersection_id
JOIN incident inc ON i.intersection_id = inc.intersection_id
WHERE inc.severity IN ('critical', 'major')
ORDER BY inc.reported_time DESC;

-- Expected Output: signal_id (int), approach (enum), signal_status (enum), incident_type (enum), reported_time (timestamp)
-- Sample Results:
-- 142 | N | operational | breakdown | 2026-04-12 20:20:59.925237
-- 143 | S | operational | accident | 2026-04-15 08:30:02.124841
-- 88  | E | maintenance | hazard   | 2026-04-10 14:15:00.759425

-- Query #3: Broken Sensor Log
-- Business Question: What maintenance tasks are assigned to sensors that are offline (i.e. inactive), and who's in charge of fixing them?
-- Complexity Features: 3-Table INNER JOIN
-- Tables Used: sensor, maintenance_task, maintenance_crew

SELECT
    s.sensor_id,
    s.status AS sensor_current_status,
    mt.task_description,
    mt.scheduled_date,
    mc.supervisor
FROM sensor s
JOIN maintenance_task mt ON s.sensor_id = mt.sensor_id
JOIN maintenance_crew mc ON mt.crew_id = mc.crew_id
WHERE s.status IN ('inactive', 'maintenance') AND mt.status = 'pending'
ORDER BY mt.scheduled_date ASC;

-- Expected Output: sensor_id (int), sensor_current_status (enum), task_description (text), scheduled_date (date), supervisor (varchar)
-- Sample Results:
-- 12  | inactive    | Repair dispatch for offline sensor | 2026-04-18 | Fred Jones
-- 55  | maintenance | Repair dispatch for offline sensor | 2026-04-20 | Ivan Toney
-- 104 | inactive    | Repair dispatch for offline sensor | 2026-04-25 | Fiona Gallagher

-- =========================
-- Category 2: Aggregate Functions
-- =========================

-- Query #4: Under-Monitored Intersections
-- Business Question: Which intersections might need infrastructure upgrades because they have fewer than a few active, operational sensors (i.e. 3)?
-- Complexity Features: Aggregate Function (COUNT), GROUP BY, HAVING
-- Tables Used: sensor

SELECT
    intersection_id,
    COUNT(sensor_id) AS active_sensor_count
FROM sensor
WHERE status = 'operational' AND intersection_id IS NOT NULL
GROUP BY intersection_id
HAVING COUNT(sensor_id) < 3
ORDER BY active_sensor_count ASC, intersection_id ASC;

-- Expected Output: intersection_id (int), active_sensor_count (bigint)
-- Sample Results:
-- 14 | 1
-- 33 | 2
-- 4  | 1

-- Query #5: Incident Resolution Performance
-- Business Question: How many incidents occur per severity level, and what are our average, fastest, and slowest resolution times?
-- Complexity Features: Aggregate Functions (COUNT, AVG, MIN, MAX), GROUP BY, HAVING
-- Tables Used: incident

SELECT
    severity,
    COUNT(incident_id) AS total_incidents,
    AVG(resolved_time - reported_time) AS avg_resolution_time,
    MIN(resolved_time - reported_time) AS fastest_resolution,
    MAX(resolved_time - reported_time) AS slowest_resolution
FROM incident
WHERE resolved_time IS NOT NULL
GROUP BY severity
HAVING COUNT(incident_id) >= 2
ORDER BY total_incidents DESC;

-- Expected Output: severity (enum), total_incidents (bigint), avg_resolution_time (interval), fastest_resolution (interval), slowest_resolution (interval)
-- Sample Results:
-- minor    | 32 | 0 years 0 mons 0 days 3 hours 9 mins 52.581924 secs  | 0 years 0 mons 0 days 1 hours 12 mins 11.385711 secs | 0 years 0 mons 0 days 4 hours 29 mins 47.258021 secs
-- moderate | 14 | 0 years 0 mons 0 days 3 hours 28 mins 36.191523 secs | 0 years 0 mons 0 days 1 hours 0 mins 28.583912 secs | 0 years 0 mons 0 days 4 hours 57 mins 25.582901 secs

-- =========================
-- Category 3: Subqueries
-- =========================

-- Query #6: Severe Delay Outliers
-- Business Question: Which specific incidents took significantly longer to resolve than the overall city-wide average resolution time?
-- Complexity Features: Subquery in WHERE clause, Interval Computation

SELECT
    incident_id,
    type AS incident_type,
    severity,
    (resolved_time - reported_time) AS time_to_resolve
FROM incident
WHERE resolved_time IS NOT NULL AND (resolved_time - reported_time) > (
    SELECT AVG(resolved_time - reported_time)
    FROM incident
    WHERE resolved_time IS NOT NULL
)
ORDER BY time_to_resolve DESC;
-- Expected Output: incident_id (int), incident_type (enum), severity (enum), time_to_resolve (interval)
-- Sample Results:
-- 42 | accident     | major    | 0 years 0 mons 0 days 5 hours 52 mins 21.543245 secs
-- 19 | construction | critical | 0 years 0 mons 0 days 4 hours 18 mins 46.252722 secs
-- 8  | hazard       | moderate | 0 years 0 mons 0 days 3 hours 35 mins 54.193852 secs