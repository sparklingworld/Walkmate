import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/walk_session.dart';

/// Manages local storage using SharedPreferences.
/// Stores user weight, preferred unit, and past walk summaries.
/// Privacy note: No location coordinates or routes are ever stored.
class StorageService {
  static const String _keyWeightKg = 'user_weight_kg';
  static const String _keyWeightUnit = 'user_weight_unit'; // 'kg' or 'lbs'
  static const String _keyPastWalks = 'past_walk_sessions';
  static const String _keyTotalDistance = 'total_distance_meters';
  static const String _keyTotalCalories = 'total_calories_burned';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Weight Management ---

  /// Default weight is 70 kg if not set yet.
  double get weightKg => _prefs.getDouble(_keyWeightKg) ?? 70.0;

  bool get hasSavedWeight => _prefs.containsKey(_keyWeightKg);

  Future<void> saveWeightKg(double weight) async {
    await _prefs.setDouble(_keyWeightKg, weight);
  }

  String get weightUnit => _prefs.getString(_keyWeightUnit) ?? 'kg';

  Future<void> saveWeightUnit(String unit) async {
    await _prefs.setString(_keyWeightUnit, unit);
  }

  double get displayWeight {
    if (weightUnit == 'lbs') {
      return weightKg * 2.20462;
    }
    return weightKg;
  }

  Future<void> saveDisplayWeight(double value, String unit) async {
    await saveWeightUnit(unit);
    if (unit == 'lbs') {
      await saveWeightKg(value / 2.20462);
    } else {
      await saveWeightKg(value);
    }
  }

  // --- Past Walk Summaries (Privacy: aggregate stats only) ---

  List<WalkSession> getPastWalks() {
    final rawList = _prefs.getStringList(_keyPastWalks) ?? [];
    return rawList
        .map((jsonStr) => WalkSession.fromJson(jsonDecode(jsonStr)))
        .toList()
        .reversed
        .toList(); // Newest first
  }

  Future<void> saveWalkSession(WalkSession session) async {
    final rawList = _prefs.getStringList(_keyPastWalks) ?? [];
    rawList.add(jsonEncode(session.toJson()));
    await _prefs.setStringList(_keyPastWalks, rawList);

    // Update cumulative totals
    final currentDist = _prefs.getDouble(_keyTotalDistance) ?? 0.0;
    await _prefs.setDouble(_keyTotalDistance, currentDist + session.distanceMeters);

    final currentCals = _prefs.getDouble(_keyTotalCalories) ?? 0.0;
    await _prefs.setDouble(_keyTotalCalories, currentCals + session.caloriesBurned);
  }

  double get totalLifetimeDistanceKm {
    final meters = _prefs.getDouble(_keyTotalDistance) ?? 0.0;
    return meters / 1000.0;
  }

  double get totalLifetimeCalories {
    return _prefs.getDouble(_keyTotalCalories) ?? 0.0;
  }

  int get totalLifetimeWalks {
    final rawList = _prefs.getStringList(_keyPastWalks) ?? [];
    return rawList.length;
  }
}
