-- This is our schema implementation, following the schema we have defined in GP1 as well as corresponding feedback/requirements for GP2.

-- Creating custom types (ENUMs for constrained values), from feedback w/GP1
CREATE TYPE intersection_type AS ENUM ('signalized', 'unsignalized', 'roundabout');
CREATE TYPE signal_approach AS ENUM ('N', 'S', 'E', 'W');
CREATE TYPE signal_timing_mode AS ENUM ('fixed', 'adaptive', 'emergency');
CREATE TYPE signal_hardware_type AS ENUM ('LED', 'incandescent', 'pedestrian');
CREATE TYPE sensor_type AS ENUM ('inductive_loop', 'radar', 'camera', 'lidar', 'acoustic');
CREATE TYPE signal_status AS ENUM ('operational', 'inactive', 'maintenance');
CREATE TYPE road_surface AS ENUM('asphalt', 'concrete', 'gravel');
CREATE TYPE incident_severity AS ENUM ('minor', 'moderate', 'major', 'critical');
CREATE TYPE incident_category_type AS ENUM('accident', 'breakdown', 'hazard', 'construction', 'event');

-- Completing all the tables with columns from GP1
CREATE TABLE INTERSECTION (
    intersection_id SERIAL PRIMARY KEY,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    capacity INTEGER NOT NULL,
    type intersection_type NOT NULL,
    elevation DECIMAL(6,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Candidate Key and Business Rules, feedback w/GP1
    CONSTRAINT uq_intersection_location UNIQUE (latitude, longitude),
    CONSTRAINT chk_capacity_positive CHECK (capacity > 0),
    CONSTRAINT chk_elevation_non_negative CHECK (elevation >= 0 OR elevation IS NULL)
);

CREATE TABLE ROAD_SEGMENT (
    road_segment_id SERIAL PRIMARY KEY,
    length DECIMAL(10,2) NOT NULL,
    surface road_surface NOT NULL,
    speed_limit INTEGER NOT NULL,
    lane_width DECIMAL(5,2) NOT NULL,
    lanes INTEGER NOT NULL,
    bike_lanes BOOLEAN DEFAULT FALSE,
    sidewalks BOOLEAN DEFAULT FALSE,
    grade DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Business Rules, feedback w/GP1
    CONSTRAINT chk_lanes_positive CHECK (lanes >= 1),
    CONSTRAINT chk_width_positive CHECK (lane_width > 0),
    CONSTRAINT chk_speed_limit CHECK (speed_limit > 0),
    CONSTRAINT chk_length_positive CHECK (length > 0),
    CONSTRAINT chk_grade_range CHECK (grade >= -0.15 AND grade <= 0.15)
);

CREATE TABLE TRAFFIC_ZONE (
    zone_id SERIAL PRIMARY KEY,
    district VARCHAR(50) NOT NULL,
    restrictions VARCHAR(100)
);

CREATE TABLE EMERGENCY_FACILITY (
    facility_id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    capacity INTEGER NOT NULL,
    contact VARCHAR(100),
    hours VARCHAR(100)
);

CREATE TABLE MAINTENANCE_CREW (
    crew_id SERIAL PRIMARY KEY,
    specialization VARCHAR(50),
    supervisor VARCHAR(100),
    certification VARCHAR(100),
    availability VARCHAR(50)
);

CREATE TABLE WEATHER_STATION (
    station_id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(20),
    capabilities VARCHAR(100),
    location_details VARCHAR(100)
);

CREATE TABLE TRAFFIC_SIGNAL (
    signal_id SERIAL PRIMARY KEY,
    intersection_id INTEGER NOT NULL REFERENCES INTERSECTION(intersection_id) ON DELETE CASCADE,
    approach signal_approach NOT NULL, 
    type signal_hardware_type NOT NULL,
    timing_mode signal_timing_mode NOT NULL,
    default_speed INTEGER,
    status signal_status DEFAULT 'operational',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Chen partial key approach, feedback w/GP1
    CONSTRAINT uq_signal_approach UNIQUE (intersection_id, approach)
);

CREATE TABLE SENSOR (
    sensor_id SERIAL PRIMARY KEY,
    type sensor_type NOT NULL,
    status sensor_status DEFAULT 'operational',
    location_details VARCHAR(100),
    transmission_frequency INTEGER,
    measured_parameter VARCHAR(50),
    road_segment_id INTEGER REFERENCES ROAD_SEGMENT(road_segment_id) ON DELETE CASCADE,
    intersection_id INTEGER REFERENCES INTERSECTION(intersection_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- We need an Exclusive OR constraint here (XOR) to ensure a sensor is linked to either an intersection or a road segment, but not both.
    CONSTRAINT chk_sensor_location_xor CHECK (
        (intersection_id IS NOT NULL AND road_segment_id IS NULL) OR 
        (intersection_id IS NULL AND road_segment_id IS NOT NULL)
    )
);

CREATE TABLE INCIDENT (
    incident_id SERIAL PRIMARY KEY,
    type incident_category_type NOT NULL,
    severity incident_severity NOT NULL,
    reported_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_time TIMESTAMP,
    verified_time TIMESTAMP,
    source VARCHAR(50),
    road_segment_id INTEGER REFERENCES ROAD_SEGMENT(road_segment_id) ON DELETE SET NULL,
    intersection_id INTEGER REFERENCES INTERSECTION(intersection_id) ON DELETE SET NULL,
    
    -- We need an Exclusive OR constraint here (XOR) to ensure a incident is linked to either an intersection or a road segment, but not both.
    CONSTRAINT chk_incident_location_xor CHECK (
        (intersection_id IS NOT NULL AND road_segment_id IS NULL) OR 
        (intersection_id IS NULL AND road_segment_id IS NOT NULL)
    )
);

CREATE TABLE PARKING_FACILITY (
    parking_facility_id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    capacity INTEGER NOT NULL,
    ev_spots INTEGER DEFAULT 0,
    accessible_spaces INTEGER DEFAULT 0,
    hourly_rate DECIMAL(6,2),
    daily_max DECIMAL(6,2),
    payment_method VARCHAR(50),
    road_segment_id INTEGER REFERENCES ROAD_SEGMENT(road_segment_id) ON DELETE SET NULL,
    intersection_id INTEGER REFERENCES INTERSECTION(intersection_id) ON DELETE SET NULL,

    -- We need an Exclusive OR constraint here (XOR) to ensure a parking facility is linked to either an intersection or a road segment, but not both.
    CONSTRAINT chk_parking_location_xor CHECK (
        (intersection_id IS NOT NULL AND road_segment_id IS NULL) OR 
        (intersection_id IS NULL AND road_segment_id IS NOT NULL)
    )
);

-- This is still creating tables but more specifically, M:N relationships
CREATE TABLE ROAD_INTERSECTION (
    road_segment_id INTEGER REFERENCES ROAD_SEGMENT(road_segment_id) ON DELETE CASCADE,
    intersection_id INTEGER REFERENCES INTERSECTION(intersection_id) ON DELETE CASCADE,
    PRIMARY KEY (road_segment_id, intersection_id)
);

CREATE TABLE ADJACENT_ROAD (
    road_segment_id INTEGER REFERENCES ROAD_SEGMENT(road_segment_id) ON DELETE CASCADE,
    adjacent_road_segment_id INTEGER REFERENCES ROAD_SEGMENT(road_segment_id) ON DELETE CASCADE,
    PRIMARY KEY (road_segment_id, adjacent_road_segment_id)
);

CREATE TABLE ZONE_ASSIGNMENT (
    zone_id INTEGER REFERENCES TRAFFIC_ZONE(zone_id) ON DELETE CASCADE,
    road_segment_id INTEGER REFERENCES ROAD_SEGMENT(road_segment_id) ON DELETE CASCADE,
    PRIMARY KEY (zone_id, road_segment_id)
);

CREATE TABLE INCIDENT_RESPONSE (
    incident_id INTEGER REFERENCES INCIDENT(incident_id) ON DELETE CASCADE,
    facility_id INTEGER REFERENCES EMERGENCY_FACILITY(facility_id) ON DELETE CASCADE,
    response_time TIMESTAMP NOT NULL,
    PRIMARY KEY (incident_id, facility_id)
);

CREATE TABLE SENSOR_STATION (
    sensor_id INTEGER REFERENCES SENSOR(sensor_id) ON DELETE CASCADE,
    station_id INTEGER REFERENCES WEATHER_STATION(station_id) ON DELETE CASCADE,
    PRIMARY KEY (sensor_id, station_id)
);

CREATE TABLE MAINTENANCE_HISTORY (
    maintenance_id SERIAL PRIMARY KEY,
    sensor_id INTEGER REFERENCES SENSOR(sensor_id) ON DELETE CASCADE,
    crew_id INTEGER REFERENCES MAINTENANCE_CREW(crew_id) ON DELETE RESTRICT,
    maintenance_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    details TEXT
);

-- This is a supporting table, added w/feedback from GP1 (it's a GP2 requirement) for CLI queries
CREATE TABLE MAINTENANCE_TASK (
    task_id SERIAL PRIMARY KEY,
    crew_id INTEGER NOT NULL REFERENCES MAINTENANCE_CREW(crew_id) ON DELETE RESTRICT,
    sensor_id INTEGER NOT NULL REFERENCES SENSOR(sensor_id) ON DELETE CASCADE, 
    task_description TEXT NOT NULL,
    scheduled_date DATE NOT NULL,
    completed_date DATE,
    status VARCHAR(50) DEFAULT 'pending'
);

CREATE INDEX idx_sensor_intersection ON SENSOR(intersection_id);
CREATE INDEX idx_sensor_road ON SENSOR(road_segment_id);
CREATE INDEX idx_incident_intersection ON INCIDENT(intersection_id);
CREATE INDEX idx_incident_road ON INCIDENT(road_segment_id);
CREATE INDEX idx_signal_intersection ON TRAFFIC_SIGNAL(intersection_id);
CREATE INDEX idx_incident_severity ON INCIDENT(severity);
CREATE INDEX idx_incident_reported_time ON INCIDENT(reported_time);

-- Automatic triggers below with updated_at timestamps
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_intersection_update
    BEFORE UPDATE ON INTERSECTION
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trigger_road_segment_update
    BEFORE UPDATE ON ROAD_SEGMENT
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trigger_traffic_signal_update
    BEFORE UPDATE ON TRAFFIC_SIGNAL
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();