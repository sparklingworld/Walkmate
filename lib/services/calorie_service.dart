/// Scientific MET (Metabolic Equivalent of Task) based calorie calculator.
///
/// Uses standard values from the Compendium of Physical Activities:
/// Formula: Calories/min = (MET * 3.5 * weightKg) / 200
///
/// Accounts for:
/// 1. User's weight (kg)
/// 2. Walking & running speed/intensity (km/h)
/// 3. Active elapsed time and resting states
class CalorieService {
  /// Returns the estimated MET value based on walking/running speed in km/h.
  static double getMetForSpeed(double speedKmh, {bool isPaused = false}) {
    if (isPaused || speedKmh < 0.8) {
      return 1.2; // Resting / stationary metabolic rate
    } else if (speedKmh < 2.5) {
      return 2.0; // Casual strolling, gentle wandering
    } else if (speedKmh < 4.0) {
      return 3.0; // Relaxed walking, comfortable pace
    } else if (speedKmh < 5.5) {
      return 3.6; // Moderate walking, purposeful stride
    } else if (speedKmh < 7.5) {
      return 4.5; // Very brisk walking / power walking
    } else if (speedKmh < 9.5) {
      return 7.5; // Jogging / light running
    } else if (speedKmh < 12.0) {
      return 9.8; // Running (6 min/km pace)
    } else {
      return 11.5; // Fast running / sprint
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
