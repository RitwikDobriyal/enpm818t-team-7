from rich.console import Console
from rich.table import Table
from config.database import DatabaseConfig
from services.traffic_service import TrafficService

console = Console()
service = TrafficService()


def show_intersection_lookup():
    try:
        intersection_id = int(input("Enter intersection ID: ").strip())
    except ValueError:
        console.print("[red]Invalid intersection ID.[/red]")
        return

    intersection = service.get_intersection_by_id(intersection_id)
    if not intersection:
        console.print("[yellow]No intersection found.[/yellow]")
        return

    table = Table(title="Intersection Details")
    table.add_column("Field")
    table.add_column("Value")
    table.add_row("Intersection ID", str(intersection.intersection_id))
    table.add_row("Latitude", str(intersection.latitude))
    table.add_row("Longitude", str(intersection.longitude))
    table.add_row("Capacity", str(intersection.capacity))
    table.add_row("Type", str(intersection.type))
    table.add_row("Elevation", str(intersection.elevation))
    console.print(table)


def show_high_incident_intersections():
    results = service.get_high_incident_intersections(days=90, limit=10)

    table = Table(title="High-Incident Intersections (Last 90 Days)")
    table.add_column("Rank")
    table.add_column("Intersection ID")
    table.add_column("Zone")
    table.add_column("Incidents")
    table.add_column("Sensors")
    table.add_column("Coordinates")

    for idx, row in enumerate(results, start=1):
        coords = f"({row['latitude']}, {row['longitude']})"
        table.add_row(
            str(idx),
            str(row["intersection_id"]),
            str(row["zone_name"]),
            str(row["incident_count"]),
            str(row["sensor_count"]),
            coords,
        )

    console.print(table)


def show_system_metrics():
    metrics = service.get_system_metrics()

    table = Table(title="System Performance Metrics")
    table.add_column("Metric")
    table.add_column("Value")

    for key, value in metrics.items():
        table.add_row(key.replace("_", " ").title(), str(value))

    console.print(table)


def show_incident_counts_by_severity():
    results = service.get_incident_counts_by_severity()

    table = Table(title="Incident Counts by Severity")
    table.add_column("Severity")
    table.add_column("Count")

    for row in results:
        table.add_row(str(row["severity"]), str(row["incident_count"]))

    console.print(table)


def main():
    DatabaseConfig.initialize()

    while True:
        console.print("\n[bold cyan]=== Traffic Management System ===[/bold cyan]")
        console.print("1. Look up intersection by ID")
        console.print("2. Show high-incident intersections")
        console.print("3. System performance metrics")
        console.print("4. Incident counts by severity")
        console.print("5. Exit")

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
            DatabaseConfig.close_all()
            console.print("[green]Goodbye![/green]")
            break
        else:
            console.print("[red]Invalid option. Please choose 1-5.[/red]")


if __name__ == "__main__":
    main()
