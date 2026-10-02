import 'package:flutter_test/flutter_test.dart';
import 'package:walkmate/services/milestone_service.dart';

void main() {
  group('MilestoneService Tests', () {
    test('Detects milestone exactly when crossing 500m boundary', () {
      // 495m -> 505m crosses 500m
      final milestone1 = MilestoneService.checkMilestone(
        currentDistanceMeters: 505.0,
        previousDistanceMeters: 495.0,
      );

      expect(milestone1, isNotNull);
      expect(milestone1!.distanceMeters, equals(500.0));
      expect(milestone1.title, contains("0.5 km done"));
      expect(milestone1.emoji, equals("🌱"));

      // 510m -> 520m does NOT cross 500m
      final milestone2 = MilestoneService.checkMilestone(
        currentDistanceMeters: 520.0,
        previousDistanceMeters: 510.0,
      );
      expect(milestone2, isNull);
    });

    test('Detects 1000m (1.0 km) and 2000m (2.0 km) milestones', () {
      final m1000 = MilestoneService.checkMilestone(
        currentDistanceMeters: 1002.0,
        previousDistanceMeters: 998.0,
      );
      expect(m1000, isNotNull);
      expect(m1000!.distanceMeters, equals(1000.0));
      expect(m1000.title, contains("1.0 km achieved"));

      final m2000 = MilestoneService.checkMilestone(
        currentDistanceMeters: 2010.0,
        previousDistanceMeters: 1980.0,
      );
      expect(m2000, isNotNull);
      expect(m2000!.distanceMeters, equals(2000.0));
      expect(m2000.title, contains("2.0 km reached"));
    });

    test('Provides rest and movement insights', () {
      final restInsight = MilestoneService.getRestInsight(0);
      expect(restInsight.title, isNotEmpty);
      expect(restInsight.category, equals("rest"));
    });
  });
}
