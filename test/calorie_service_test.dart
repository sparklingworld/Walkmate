import 'package:flutter_test/flutter_test.dart';
import 'package:walkmate/services/calorie_service.dart';

void main() {
  group('CalorieService MET Calculation Tests', () {
    test('Calculates correct MET for walking and running speeds', () {
      // Resting / standing
      expect(CalorieService.getMetForSpeed(0.0), equals(1.2));
      expect(CalorieService.getMetForSpeed(0.0, isPaused: true), equals(1.2));

      // Strolling (< 2.5 km/h)
      expect(CalorieService.getMetForSpeed(2.0), equals(2.0));

      // Relaxed walk (2.5 - 4.0 km/h)
      expect(CalorieService.getMetForSpeed(3.0), equals(3.0));

      // Moderate walk (4.0 - 5.5 km/h)
      expect(CalorieService.getMetForSpeed(5.0), equals(3.6));

      // Power walk (5.5 - 7.5 km/h)
      expect(CalorieService.getMetForSpeed(6.5), equals(4.5));

      // Jogging (7.5 - 9.5 km/h)
      expect(CalorieService.getMetForSpeed(8.5), equals(7.5));

      // Running (9.5 - 12.0 km/h)
      expect(CalorieService.getMetForSpeed(10.0), equals(9.8));
    });

    test('Calculates reasonable calories for 60 min moderate walk at 70 kg', () {
      // 70 kg person walking 60 minutes at moderate pace (MET 3.6)
      // Calories = (3.6 * 3.5 * 70) / 200 * 60 = 4.41 * 60 = ~264.6 kcal
      final calories = CalorieService.calculateCalories(
        weightKg: 70.0,
        met: 3.6,
        duration: const Duration(minutes: 60),
      );

      expect(calories, closeTo(264.6, 1.0));
    });

    test('Incremental 1-second calorie calculation works continuously', () {
      final stepCal = CalorieService.calculateIncrementalCalories(
        weightKg: 70.0,
        currentSpeedKmh: 5.0, // MET 3.6
        stepDuration: const Duration(seconds: 1),
      );

      // (3.6 * 3.5 * 70) / 200 * (1 / 60) = 4.41 / 60 = ~0.0735 kcal / second
      expect(stepCal, closeTo(0.0735, 0.01));
    });
  });
}
