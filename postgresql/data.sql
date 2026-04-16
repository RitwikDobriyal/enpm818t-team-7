-- =========================================================
-- EXPLICIT ROW COUNTS (THAT MEETS REQUIREMENTS)
-- intersections: 64
-- traffic_signals: 192
-- sensors: 192
-- road_segments: 70
-- incidents: 80
-- maintenance_crews: 12
-- maintenance_history: 120
-- maintenance_tasks: 105
-- =========================================================


-- =========================
-- TRAFFIC ZONES
-- =========================
INSERT INTO traffic_zone (zone_id, district, restrictions) VALUES
(1,'Downtown','Low speed, strict enforcement'),
(2,'Residential','Traffic calming'),
(3,'Industrial','Heavy vehicles'),
(4,'School','School zone enforcement'),
(5,'Commercial','Moderate control'),
(6,'Mixed Use','Adaptive signals');


-- =========================
-- INTERSECTIONS (64 GRID)
-- =========================
INSERT INTO intersection (intersection_id, latitude, longitude, capacity, type, elevation)
SELECT 
    i,
    38.89 + (i/8)*0.003 + random()*0.0005,
    -77.05 + (i%8)*0.004 + random()*0.0005,
    floor(random()*1000 + 1500)::int,
    -- FIXED: Using floor() to prevent array out-of-bounds
    (ARRAY['signalized','unsignalized','roundabout'])[floor(random()*3 + 1)::int]::intersection_type,
    (random()*15)::numeric(6,2)
FROM generate_series(1,64) i;


-- =========================
-- ROAD SEGMENTS (70)
-- =========================
INSERT INTO road_segment (road_segment_id, length, surface, speed_limit, lane_width, lanes, bike_lanes, sidewalks, grade)
SELECT
    i,
    (300 + random()*700)::numeric(10,2),
    (ARRAY['asphalt','concrete','gravel'])[floor(random()*3 + 1)::int]::road_surface,
    (25 + floor(random()*30)::int),
    (3.0 + random()*1.0)::numeric(5,2),
    (ARRAY[2,4,6])[floor(random()*3 + 1)::int],
    (random() > 0.5),
    (random() > 0.3),
    (random()*0.3 - 0.15)::numeric(5,2)
FROM generate_series(1,70) i;


-- =========================
-- ROAD ↔ INTERSECTION LINKS
-- =========================
INSERT INTO road_intersection
SELECT
    r.road_segment_id,
    ((r.road_segment_id + g.i) % 64) + 1
FROM road_segment r
CROSS JOIN generate_series(1,2) g(i);


-- =========================
-- ADJACENT ROADS
-- =========================
INSERT INTO adjacent_road
SELECT i, i+1
FROM generate_series(1,69) i;


-- =========================
-- TRAFFIC SIGNALS (3 PER INTERSECTION = 192)
-- =========================
INSERT INTO traffic_signal (signal_id, intersection_id, approach, type, timing_mode, default_speed, status)
SELECT
    row_number() OVER (),
    i.intersection_id,
    a.approach::signal_approach,
    (ARRAY['LED','incandescent','pedestrian'])[floor(random()*3 + 1)::int]::signal_hardware_type,
    (ARRAY['fixed','adaptive','emergency'])[floor(random()*3 + 1)::int]::signal_timing_mode,
    (25 + floor(random()*25)::int),
    (CASE WHEN random() < 0.9 THEN 'operational'
          WHEN random() < 0.5 THEN 'maintenance'
          ELSE 'inactive' END)::signal_status
FROM intersection i
CROSS JOIN (VALUES ('N'),('S'),('E')) AS a(approach);


-- =========================
-- SENSORS (3 PER INTERSECTION = 192)
-- =========================
INSERT INTO sensor (sensor_id, type, status, location_details, transmission_frequency, measured_parameter, intersection_id)
SELECT
    row_number() OVER (),
    (ARRAY['inductive_loop','radar','camera','lidar','acoustic'])[floor(random()*5 + 1)::int]::sensor_type,
    (CASE WHEN random() < 0.85 THEN 'operational'
          WHEN random() < 0.5 THEN 'maintenance'
          ELSE 'inactive' END)::signal_status,
    'Pole ' || chr(65 + floor(random()*5)::int),
    floor(random()*10 + 1)::int,
    (ARRAY['flow','speed','vehicle_count','noise'])[floor(random()*4 + 1)::int],
    i.intersection_id
FROM intersection i
CROSS JOIN generate_series(1,3);


-- =========================
-- MAINTENANCE CREWS (12)
-- =========================
INSERT INTO maintenance_crew (crew_id, specialization, supervisor, certification, availability)
SELECT
    i,
    (ARRAY['electrical','mechanical','civil','software'])[floor(random()*4 + 1)::int],
    'Supervisor ' || i,
    'Level ' || floor(random()*3 + 1)::int,
    (ARRAY['available','busy'])[floor(random()*2 + 1)::int]
FROM generate_series(1,12) i;


-- =========================
-- MAINTENANCE HISTORY (120)
-- =========================
INSERT INTO maintenance_history (maintenance_id, sensor_id, crew_id, maintenance_date, details)
SELECT
    i,
    floor(random()*191 + 1)::int,
    floor(random()*11 + 1)::int,
    NOW() - (random()*90 || ' days')::interval,
    (ARRAY['inspection','repair','upgrade','calibration'])[floor(random()*4 + 1)::int]
FROM generate_series(1,120) i;

-- =========================
-- MAINTENANCE TASKS (105)
-- =========================
INSERT INTO maintenance_task (task_id, crew_id, sensor_id, task_description, scheduled_date, completed_date, status)
SELECT
    i,
    floor(random()*11 + 1)::int,
    floor(random()*191 + 1)::int,
    'Scheduled routine maintenance',
    CURRENT_DATE - floor(random()*30)::int,
    CURRENT_DATE - floor(random()*10)::int,
    'completed'
FROM generate_series(1, 105) i;


-- =========================
-- INCIDENTS (80, RUSH HOUR BIAS)
-- =========================
INSERT INTO incident (incident_id, type, severity, reported_time, resolved_time, source, intersection_id)
SELECT
    i,
    (ARRAY['accident','breakdown','hazard','construction','event'])[floor(random()*5 + 1)::int]::incident_category_type,
    (ARRAY['minor','moderate','major','critical'])[floor(random()*4 + 1)::int]::incident_severity,
    NOW() - (random()*90 || ' days')::interval
        + (CASE WHEN random() < 0.5 THEN interval '8 hours' ELSE interval '17 hours' END),
    CASE WHEN random() < 0.7 THEN NOW() - (random()*60 || ' minutes')::interval ELSE NULL END,
    (ARRAY['camera','sensor','report','police'])[floor(random()*4 + 1)::int],
    floor(random()*63 + 1)::int
FROM generate_series(1,80) i;


-- =========================
-- EMERGENCY FACILITIES (10)
-- =========================
INSERT INTO emergency_facility (facility_id, type, capacity, contact, hours)
SELECT
    i,
    (ARRAY['Hospital','Fire Station','Police Station'])[floor(random()*3 + 1)::int],
    floor(random()*300 + 50)::int,
    '202-555-' || (1000 + i),
    '24/7'
FROM generate_series(1,10) i;


-- =========================
-- INCIDENT RESPONSES
-- =========================
INSERT INTO incident_response
SELECT
    i.incident_id,
    floor(random()*9 + 1)::int,
    i.reported_time + interval '5 minutes'
FROM incident i;


-- =========================
-- WEATHER STATIONS (6)
-- =========================
INSERT INTO weather_station (station_id, type, status, capabilities, location_details)
SELECT
    i,
    'meteorological',
    'active',
    'temp,humidity,wind',
    'Zone ' || i
FROM generate_series(1,6) i;


-- =========================
-- SENSOR-STATION LINKS
-- =========================
INSERT INTO sensor_station
SELECT
    s.sensor_id,
    floor(random()*5 + 1)::int
FROM sensor s
LIMIT 150;


-- =========================
-- PARKING FACILITIES (12)
-- =========================
INSERT INTO parking_facility (parking_facility_id, type, capacity, ev_spots, accessible_spaces, hourly_rate, daily_max, payment_method, intersection_id)
SELECT
    i,
    (ARRAY['garage','surface','street'])[floor(random()*3 + 1)::int],
    floor(random()*300 + 50)::int,
    floor(random()*30)::int,
    floor(random()*20)::int,
    (2 + random()*5)::numeric(6,2),
    (10 + random()*30)::numeric(6,2),
    (ARRAY['card','cash','app'])[floor(random()*3 + 1)::int],
    floor(random()*63 + 1)::int
FROM generate_series(1,12) i;


-- =========================
-- ZONE ASSIGNMENTS
-- =========================
INSERT INTO zone_assignment
SELECT
    floor(random()*5 + 1)::int,
    r.road_segment_id
FROM road_segment r;