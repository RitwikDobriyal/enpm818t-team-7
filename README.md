# Traffic Management System

A comprehensive traffic management system built with Python and PostgreSQL to monitor intersections, traffic signals, incidents, and sensors in a city environment.

## Prerequisites

- Python 3.8: Application code
- PostgreSQL 12: Database server

## Setup

### Database Setup
1) Install PostgreSQL (if not already installed)
2) Create the database:
- psql -U postgres
- CREATE DATABASE enpm818t_team_7
- GRANT ALL PRIVILEGES ON DATABASE enpm818t_team_7 TO your_username;
- \q
OR
- Install DataGrip (if not already installed)
- Create a new database, enpm818t_team_7
- Ensure schema is connected to files loaded into application (shown below)
3) Load schema and data:
- psql -U your_username -d enpm818t_team_7 postgresql/schema.sql
- psql -U your_username -d enpm818t_team_7 postgresql/data.sql
OR
- Simply drag and drop the files into DataGrip and execute the sql files.

### Environment Configuration
1) Copy the environment template -- either do `cp .env.example .env` or manually copy the file in an IDE like VSCode and rename it, and then edit the .env file with your database credentials. 

### Install Dependencies
1) Dependencies are featured in this project. Please run the following, ideally in a virtual environment.
`pip install -r requirements` -- this will install:
- psycopg[binary] - PostgreSQL adapter for Python
- psycopg-pool - Connection pooling for PostgreSQL
- python-dotenv - Environment variable management

## Running the Application
To run the application, one will need to go to the project root directory, and execute the main application file:
`python src/cli/main.py`
The application provides an interactive command-line interface with the following options:
1) Look up intersection by ID: Enter an intersection ID to view its details.
2) Show high-incident intersections: Display intersections with the most incidents in the last 90 days.
3) Show system-wide performance metrics: View overall system statistics.
4) Show incident counts by severity: See incident distribution by severity level.
5) Exit: Close the application.

## Project Structure
├── README.md                 # This file
├── requirements.txt          # Python dependencies
├── .env.example              # Environment configuration template
├── postgresql/               # Database files
│   ├── schema.sql            # Database schema definition
│   ├── data.sql              # Sample data
│   └── queries.sql           # Analytical queries
└── src/                      # Source code
    ├── cli/
    │   └── main.py           # Command-line interface
    ├── config/
    │   └── database.py       # Database configuration
    ├── models/               # Data models
    ├── repositories/         # Data access layer
    └── services/             # Business logic