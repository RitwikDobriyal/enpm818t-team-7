# main.py
from config.database import DatabaseConfig
from services.traffic_service import TrafficService


service = TrafficService()


def show_intersection_lookup():
    try:
        intersection_id = int(input("Enter intersection ID: ").strip())
    except ValueError:
        print("Invalid intersection ID.")
        return

    intersection = service.get_intersection_by_id(intersection_id)

    if not intersection:
        print("No intersection found.")
        return

    print("\n--- Intersection Details ---")
    print(f"Intersection ID: {intersection.intersection_id}")
    print(f"Latitude: {intersection.latitude}")
    print(f"Longitude: {intersection.longitude}")
    print(f"Capacity: {intersection.capacity}")
    print(f"Type: {intersection.type}")
    print(f"Elevation: {intersection.elevation}")


def show_high_incident_intersections():
    results = service.get_high_incident_intersections(days=90, limit=10)

    print("\n--- High-Incident Intersections (Last 90 Days) ---")
    if not results:
        print("No results found.")
        return

    for idx, row in enumerate(results, start=1):
        print(f"\nRank #{idx}")
        print(f"Intersection ID: {row['intersection_id']}")
        print(f"Zone: {row['zone_name']}")
        print(f"Incidents: {row['incident_count']}")
        print(f"Sensors: {row['sensor_count']}")
        print(f"Coordinates: ({row['latitude']}, {row['longitude']})")


def show_system_metrics():
    metrics = service.get_system_metrics()

    print("\n--- System Performance Metrics ---")
    print(f"Total Intersections: {metrics['total_intersections']}")
    print(f"Total Incidents: {metrics['total_incidents']}")
    print(f"Total Sensors: {metrics['total_sensors']}")
    print(f"Average Sensors per Intersection: {metrics['avg_sensors_per_intersection']}")
    print(f"Open Maintenance Tasks: {metrics['open_maintenance_tasks']}")


def show_incident_counts_by_severity():
    results = service.get_incident_counts_by_severity()

    print("\n--- Incident Counts by Severity ---")
    if not results:
        print("No results found.")
        return

    for row in results:
        print(f"{row['severity']}: {row['incident_count']}")


def main():
    DatabaseConfig.initialize()

    try:
        while True:
            print("\n=== Traffic Management System ===")
            print("1. Look up intersection by ID")
            print("2. Show high-incident intersections")
            print("3. Show system-wide performance metrics")
            print("4. Show incident counts by severity")
            print("5. Exit")

            choice = input("Select option: ").strip()

            if choice == "1":
                show_intersection_lookup()
            elif choice == "2":
                show_high_incident_intersections()
            elif choice == "3":
                show_system_metrics()
            elif choice == "4":
                show_incident_counts_by_severity()
            elif choice == "5":
                print("Goodbye!")
                break
            else:
                print("Invalid option. Please choose 1-5.")
    finally:
        DatabaseConfig.close_all()


if __name__ == "__main__":
    main()
