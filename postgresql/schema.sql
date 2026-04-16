-- This is our schema implementation. 
-- Replace these comments with the following:
--      Custom types: ENUMs for constrained values
--      All tables: Complete with all columns from GP1
--      Primary keys: All defined correctly
--      Foreign keys: With ON DELETE/UPDATE rules
--      Check constraints: Business rules from your GP1 entity catalog
--      NOT NULL constraints: All mandatory fields
--      UNIQUE constraints: All candidate keys
--      Indexes: Strategic indexes for query performance
--      Triggers: Automatic updated_at timestamps


-- Creating custom types (ENUMs for constrained values), from feedback w/GP1
CREATE TYPE intersection_type AS ENUM ('signalized', 'unsignalized', 'roundabout');
CREATE TYPE signal_approach AS ENUM ('N', 'S', 'E', 'W');
CREATE TYPE signal_timing_mode AS ENUM ('fixed', 'adaptive', 'emergency');
CREATE TYPE signal_hardware_type AS ENUM ('LED', 'incandescent', 'pedestrian')
CREATE TYPE sensor_type AS ENUM ('inductive_loop', 'radar', 'camera', 'lidar', 'acoustic');
CREATE TYPE signal_status AS ENUM ('operational', 'inactive', 'maintenance');
CREATE TYPE road_surface AS ENUM('asphalt', 'concrete', 'gravel');
CREATE TYPE incident_severity AS ENUM ('minor', 'moderate', 'major', 'critical');
CREATE TYPE incident_category_type AS ENUM('accident', 'breakdown', 'hazard', 'construction', 'event');