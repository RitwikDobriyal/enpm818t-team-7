-- Replace the comments again in this file with the queries we would need to run. 
-- Make sure to follow the following format for every query:

-- Query #X: [Title]
-- Business Question: [Problem being solved]
-- Complexity Features: [JOINs, aggregates, subqueries]
-- Tables Used: [List all tables]

-- [YOUR SQL QUERY]

-- Expected Output: [Description of result columns]
-- Sample Results: [First 3 rows with representative data]

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

