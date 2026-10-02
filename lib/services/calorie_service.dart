/// Scientific MET (Metabolic Equivalent of Task) based calorie calculator.
///
/// Uses standard values from the Compendium of Physical Activities:
/// Formula: Calories/min = (MET * 3.5 * weightKg) / 200
///
/// Accounts for:
/// 1. User's weight (kg)
/// 2. Walking speed/intensity (km/h)
/// 3. Active elapsed time
class CalorieService {
  /// Returns the estimated MET value based on walking speed in km/h.
  static double getMetForSpeed(double speedKmh, {bool isPaused = false}) {
    if (isPaused) {
      return 1.2; // Resting metabolic rate
    }

    if (speedKmh <= 0.5) {
      return 1.3; // Barely moving / gentle pause
    } else if (speedKmh < 2.5) {
      return 2.0; // Casual strolling, window shopping
    } else if (speedKmh < 3.5) {
      return 2.8; // Relaxed walking, gentle pace
    } else if (speedKmh < 4.5) {
      return 3.3; // Moderate walking, steady stroll
    } else if (speedKmh < 5.5) {
      return 3.8; // Brisk walking, purposeful stride
    } else if (speedKmh < 6.5) {
      return 4.3; // Very brisk, power walking
    } else {
      return 5.0; // Fast walking / uphill or hurried pace
    }
  }

  /// Calculates total calories burned given weight in kg, MET value, and duration.
  static double calculateCalories({
    required double weightKg,
    required double met,
    required Duration duration,
  }) {
    final minutes = duration.inMilliseconds / 60000.0;
    if (minutes <= 0 || weightKg <= 0) return 0.0;

    // Calories per min = (MET * 3.5 * weightKg) / 200
    final caloriesPerMin = (met * 3.5 * weightKg) / 200.0;
    return caloriesPerMin * minutes;
  }

  /// Incremental calorie burn for a delta time step (e.g. 1 second tick).
  static double calculateIncrementalCalories({
    required double weightKg,
    required double currentSpeedKmh,
    required Duration stepDuration,
    bool isPaused = false,
  }) {
    final met = getMetForSpeed(currentSpeedKmh, isPaused: isPaused);
    final minutes = stepDuration.inMilliseconds / 60000.0;
    return ((met * 3.5 * weightKg) / 200.0) * minutes;
  }

  /// Formatted calorie display with 1 decimal place or rounded
  static String formatCalories(double calories) {
    if (calories < 10) {
      return calories.toStringAsFixed(1);
    }
    return calories.round().toString();
  }
}
