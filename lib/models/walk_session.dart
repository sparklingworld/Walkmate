/// Represents the aggregate summary of a completed walk.
/// Privacy Guarantee: No GPS coordinates, route points, or geolocations
/// are stored. Only aggregate metrics (distance, duration, calories, speed).
class WalkSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double distanceMeters;
  final Duration duration;
  final double caloriesBurned;
  final double averageSpeedKmh;
  final String? photoPath;
  final String? customNote;
  final String encouragingPhrase;

  WalkSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.distanceMeters,
    required this.duration,
    required this.caloriesBurned,
    required this.averageSpeedKmh,
    this.photoPath,
    this.customNote,
    required this.encouragingPhrase,
  });

  double get distanceKm => distanceMeters / 1000.0;

  /// Returns pace formatted as mm'ss" per kilometer
  String get formattedPace {
    if (distanceKm <= 0.05 || duration.inSeconds < 10) return "--'--\"";
    final totalMinutes = duration.inSeconds / 60.0;
    final pacePerKm = totalMinutes / distanceKm;
    if (pacePerKm > 60 || pacePerKm < 4) return "--'--\""; // Out of normal walking range
    final paceMin = pacePerKm.floor();
    final paceSec = ((pacePerKm - paceMin) * 60).round();
    return "$paceMin'${paceSec.toString().padLeft(2, '0')}\"";
  }

  /// Formatted duration string (HH:MM:SS or MM:SS)
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'distanceMeters': distanceMeters,
        'durationSeconds': duration.inSeconds,
        'caloriesBurned': caloriesBurned,
        'averageSpeedKmh': averageSpeedKmh,
        'photoPath': photoPath,
        'customNote': customNote,
        'encouragingPhrase': encouragingPhrase,
      };

  factory WalkSession.fromJson(Map<String, dynamic> json) {
    return WalkSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      duration: Duration(seconds: json['durationSeconds'] as int),
      caloriesBurned: (json['caloriesBurned'] as num).toDouble(),
      averageSpeedKmh: (json['averageSpeedKmh'] as num).toDouble(),
      photoPath: json['photoPath'] as String?,
      customNote: json['customNote'] as String?,
      encouragingPhrase: json['encouragingPhrase'] as String? ?? 'A step forward 🌱',
    );
  }
}
