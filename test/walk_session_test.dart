import 'package:flutter_test/flutter_test.dart';
import 'package:walkmate/models/walk_session.dart';

void main() {
  group('WalkSession Model Tests', () {
    test('Calculates distanceKm, pace and duration formatting accurately', () {
      final session = WalkSession(
        id: '123',
        startTime: DateTime(2026, 10, 2, 10, 0),
        endTime: DateTime(2026, 10, 2, 10, 30),
        distanceMeters: 2500.0,
        duration: const Duration(minutes: 30, seconds: 0),
        caloriesBurned: 120.0,
        averageSpeedKmh: 5.0,
        encouragingPhrase: 'A gentle step forward 🌱',
      );

      expect(session.distanceKm, equals(2.5));
      expect(session.formattedDuration, equals('30:00'));
      // 30 minutes for 2.5 km = 12 min/km -> 12'00"
      expect(session.formattedPace, equals("12'00\""));
    });

    test('Serializes to and from JSON without preserving any GPS tracks', () {
      final session = WalkSession(
        id: '456',
        startTime: DateTime(2026, 10, 2, 14, 0),
        endTime: DateTime(2026, 10, 2, 14, 45),
        distanceMeters: 3800.0,
        duration: const Duration(minutes: 45, seconds: 12),
        caloriesBurned: 185.0,
        averageSpeedKmh: 5.04,
        photoPath: '/path/to/photo.jpg',
        customNote: 'Sunny park stroll',
        encouragingPhrase: 'Mind clear, feet grounded ✨',
      );

      final json = session.toJson();
      expect(json.containsKey('latitudes'), isFalse);
      expect(json.containsKey('longitudes'), isFalse);
      expect(json.containsKey('route'), isFalse);

      final deserialized = WalkSession.fromJson(json);
      expect(deserialized.id, equals('456'));
      expect(deserialized.distanceMeters, equals(3800.0));
      expect(deserialized.caloriesBurned, equals(185.0));
      expect(deserialized.customNote, equals('Sunny park stroll'));
    });
  });
}
