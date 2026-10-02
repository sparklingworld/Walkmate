import 'package:flutter_test/flutter_test.dart';
import 'package:walkmate/services/calorie_service.dart';

void main() {
  group('CalorieService MET Calculation Tests', () {
    test('Calculates correct MET for different walking speeds', () {
      // Resting / standing
      expect(CalorieService.getMetForSpeed(0.0), equals(1.3));
      expect(CalorieService.getMetForSpeed(0.0, isPaused: true), equals(1.2));

      // Strolling (< 2.5 km/h)
      expect(CalorieService.getMetForSpeed(2.0), equals(2.0));

      // Relaxed walk (2.5 - 3.5 km/h)
      expect(CalorieService.getMetForSpeed(3.0), equals(2.8));

      // Moderate walk (3.5 - 4.5 km/h)
      expect(CalorieService.getMetForSpeed(4.0), equals(3.3));

      // Brisk walk (4.5 - 5.5 km/h)
      expect(CalorieService.getMetForSpeed(5.0), equals(3.8));

      // Fast walk (> 6.5 km/h)
      expect(CalorieService.getMetForSpeed(7.0), equals(5.0));
    });

    test('Calculates reasonable calories for 60 min moderate walk at 70 kg', () {
      // 70 kg person walking 60 minutes at moderate pace (MET 3.3)
      // Calories = (3.3 * 3.5 * 70) / 200 * 60 = 4.0425 * 60 = ~242.55 kcal
      final calories = CalorieService.calculateCalories(
        weightKg: 70.0,
        met: 3.3,
        duration: const Duration(minutes: 60),
      );

      expect(calories, closeTo(242.55, 1.0));
    });

    test('Incremental 1-second calorie calculation works continuously', () {
      final stepCal = CalorieService.calculateIncrementalCalories(
        weightKg: 70.0,
        currentSpeedKmh: 4.0,
        stepDuration: const Duration(seconds: 1),
      );

      // (3.3 * 3.5 * 70) / 200 * (1 / 60) = 4.0425 / 60 = ~0.067375 kcal / second
      expect(stepCal, closeTo(0.067, 0.01));
    });
  });
}
