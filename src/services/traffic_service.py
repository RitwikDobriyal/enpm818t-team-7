from repositories.intersection_repo import IntersectionRepository
from repositories.analytics_repo import AnalyticsRepository


class TrafficService:
    def __init__(self):
        self.intersection_repo = IntersectionRepository()
        self.analytics_repo = AnalyticsRepository()

    def get_intersection_by_id(self, intersection_id):
        return self.intersection_repo.find_by_id(intersection_id)

    def get_high_incident_intersections(self, days=90, limit=10):
        return self.analytics_repo.get_high_incident_intersections(days, limit)

    def get_system_metrics(self):
        return self.analytics_repo.get_system_metrics()

    def get_incident_counts_by_severity(self):
        return self.analytics_repo.get_incident_counts_by_severity()
