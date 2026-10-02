/// Milestone reached every 500 meters during a walk session.
class MilestoneInfo {
  final int milestoneIndex; // 1 = 500m, 2 = 1000m, 3 = 1500m, etc.
  final double distanceMeters;
  final String title;
  final String message;
  final String insight;
  final String emoji;

  MilestoneInfo({
    required this.milestoneIndex,
    required this.distanceMeters,
    required this.title,
    required this.message,
    required this.insight,
    required this.emoji,
  });

  double get distanceKm => distanceMeters / 1000.0;
}
