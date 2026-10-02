import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/milestone_info.dart';
import '../models/movement_insight.dart';
import '../models/walk_session.dart';
import 'calorie_service.dart';
import 'milestone_service.dart';

enum WalkStatus {
  idle,
  requestingPermission,
  tracking,
  paused,
  stopped,
}

/// Core walking tracker service.
///
/// PRIVACY GUARANTEE:
/// - GPS coordinates are used exclusively in real-time to compute distance deltas.
/// - NO coordinates, tracks, breadcrumbs, or routes are ever stored in memory or on disk.
/// - The location stream is immediately stopped and detached upon ending the walk.
class TrackingService extends ChangeNotifier {
  WalkStatus _status = WalkStatus.idle;
  WalkStatus get status => _status;

  bool get isTracking => _status == WalkStatus.tracking;
  bool get isPaused => _status == WalkStatus.paused;
  bool get isActive => _status == WalkStatus.tracking || _status == WalkStatus.paused;

  // Real-time walk metrics
  double _cumulativeDistanceMeters = 0.0;
  double get cumulativeDistanceMeters => _cumulativeDistanceMeters;
  double get cumulativeDistanceKm => _cumulativeDistanceMeters / 1000.0;

  double _currentSpeedKmh = 0.0;
  double get currentSpeedKmh => _currentSpeedKmh;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  double _caloriesBurned = 0.0;
  double get caloriesBurned => _caloriesBurned;

  DateTime? _walkStartTime;
  double _userWeightKg = 70.0;

  // Milestone and Insight states
  MilestoneInfo? _latestMilestone;
  MilestoneInfo? get latestMilestone => _latestMilestone;

  MovementInsight? _currentInsight;
  MovementInsight? get currentInsight => _currentInsight;

  // Temporary GPS state (NEVER saved or stored as a path)
  double? _lastLatitude;
  double? _lastLongitude;
  DateTime? _lastPositionTime;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _tickerTimer;
  int _insightTimerSeconds = 0;

  /// Checks and requests location permissions.
  Future<bool> checkAndRequestPermission() async {
    _status = WalkStatus.requestingPermission;
    notifyListeners();

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _status = WalkStatus.idle;
      notifyListeners();
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _status = WalkStatus.idle;
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _status = WalkStatus.idle;
      notifyListeners();
      return false;
    }

    _status = WalkStatus.idle;
    notifyListeners();
    return true;
  }

  /// Starts a temporary tracking session.
  Future<bool> startWalk({required double userWeightKg}) async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return false;

    _userWeightKg = userWeightKg;
    _cumulativeDistanceMeters = 0.0;
    _currentSpeedKmh = 0.0;
    _duration = Duration.zero;
    _caloriesBurned = 0.0;
    _latestMilestone = null;
    _currentInsight = MovementInsight.defaultInsights.first;
    _lastLatitude = null;
    _lastLongitude = null;
    _lastPositionTime = null;
    _walkStartTime = DateTime.now();
    _status = WalkStatus.tracking;
    _insightTimerSeconds = 0;

    // Start GPS position stream
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3, // Minimal 3-meter threshold to prevent stationary jitter
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_onPositionUpdate, onError: (error) {
      debugPrint("WalkMate GPS Error: $error");
    });

    // Start active 1-second ticker for duration and continuous calorie increment
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), _onSecondTick);

    notifyListeners();
    return true;
  }

  void _onPositionUpdate(Position position) {
    if (_status != WalkStatus.tracking) return;

    // Reject weak accuracy readings (> 35m) to prevent GPS bounce
    if (position.accuracy > 35) return;

    final now = DateTime.now();

    if (_lastLatitude != null && _lastLongitude != null) {
      final deltaMeters = Geolocator.distanceBetween(
        _lastLatitude!,
        _lastLongitude!,
        position.latitude,
        position.longitude,
      );

      // Sanity check: filter out teleports or driving speeds (> 20 km/h = ~5.5 m/s)
      final secondsDiff = _lastPositionTime != null
          ? now.difference(_lastPositionTime!).inMilliseconds / 1000.0
          : 1.0;

      final calculatedSpeedMps = secondsDiff > 0 ? (deltaMeters / secondsDiff) : 0.0;
      final calculatedSpeedKmh = calculatedSpeedMps * 3.6;

      if (calculatedSpeedKmh <= 18.0 && deltaMeters > 1.5) {
        final previousDistance = _cumulativeDistanceMeters;
        _cumulativeDistanceMeters += deltaMeters;

        // Smooth speed update
        if (position.speed >= 0.2) {
          _currentSpeedKmh = (_currentSpeedKmh * 0.4) + (position.speed * 3.6 * 0.6);
        } else {
          _currentSpeedKmh = (_currentSpeedKmh * 0.5) + (calculatedSpeedKmh * 0.5);
        }

        // Check for 500m milestone
        final milestone = MilestoneService.checkMilestone(
          currentDistanceMeters: _cumulativeDistanceMeters,
          previousDistanceMeters: previousDistance,
        );

        if (milestone != null) {
          _latestMilestone = milestone;
        }
      }
    }

    // Temporary real-time reference: NEVER stored in a history list
    _lastLatitude = position.latitude;
    _lastLongitude = position.longitude;
    _lastPositionTime = now;

    notifyListeners();
  }

  void _onSecondTick(Timer timer) {
    if (_status == WalkStatus.tracking) {
      _duration += const Duration(seconds: 1);

      // Calculate incremental calories for 1 second of active walking
      final incrementalCals = CalorieService.calculateIncrementalCalories(
        weightKg: _userWeightKg,
        currentSpeedKmh: _currentSpeedKmh,
        stepDuration: const Duration(seconds: 1),
        isPaused: false,
      );
      _caloriesBurned += incrementalCals;

      // Cycle insight every 120 seconds
      _insightTimerSeconds++;
      if (_insightTimerSeconds >= 120) {
        _insightTimerSeconds = 0;
        final list = MovementInsight.defaultInsights;
        final nextIndex = (list.indexOf(_currentInsight ?? list.first) + 1) % list.length;
        _currentInsight = list[nextIndex];
      }

      notifyListeners();
    } else if (_status == WalkStatus.paused) {
      // Calculate light resting calories while paused
      final incrementalCals = CalorieService.calculateIncrementalCalories(
        weightKg: _userWeightKg,
        currentSpeedKmh: 0.0,
        stepDuration: const Duration(seconds: 1),
        isPaused: true,
      );
      _caloriesBurned += incrementalCals;
      notifyListeners();
    }
  }

  void dismissMilestone() {
    _latestMilestone = null;
    notifyListeners();
  }

  /// Pauses the current walk.
  void pauseWalk() {
    if (_status == WalkStatus.tracking) {
      _status = WalkStatus.paused;
      _currentSpeedKmh = 0.0;
      _currentInsight = MilestoneService.getRestInsight(DateTime.now().minute);
      notifyListeners();
    }
  }

  /// Resumes the current walk.
  void resumeWalk() {
    if (_status == WalkStatus.paused) {
      _status = WalkStatus.tracking;
      // Reset coordinates so we don't calculate leap during pause
      _lastLatitude = null;
      _lastLongitude = null;
      _currentInsight = MovementInsight.defaultInsights.first;
      notifyListeners();
    }
  }

  /// Stops the walk session and generates the final WalkSession summary.
  /// PRIVACY NOTE: GPS coordinates are completely cleared from memory immediately.
  WalkSession stopWalk({String? photoPath, String? customNote, String encouragingPhrase = "A gentle step forward 🌱"}) {
    _status = WalkStatus.stopped;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _tickerTimer?.cancel();
    _tickerTimer = null;

    final endTime = DateTime.now();
    final startTime = _walkStartTime ?? endTime.subtract(_duration);

    // Compute average speed in km/h
    final totalHours = _duration.inSeconds / 3600.0;
    final avgSpeedKmh = (totalHours > 0 && cumulativeDistanceKm > 0)
        ? (cumulativeDistanceKm / totalHours)
        : 0.0;

    final session = WalkSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: startTime,
      endTime: endTime,
      distanceMeters: _cumulativeDistanceMeters,
      duration: _duration,
      caloriesBurned: _caloriesBurned,
      averageSpeedKmh: avgSpeedKmh,
      photoPath: photoPath,
      customNote: customNote,
      encouragingPhrase: encouragingPhrase,
    );

    // Completely clear raw GPS coordinates
    _lastLatitude = null;
    _lastLongitude = null;
    _lastPositionTime = null;

    notifyListeners();
    return session;
  }

  /// Average pace formatted as mm'ss" /km
  String get formattedPace {
    if (cumulativeDistanceKm <= 0.05 || _duration.inSeconds < 10) return "--'--\"";
    final totalMinutes = _duration.inSeconds / 60.0;
    final pacePerKm = totalMinutes / cumulativeDistanceKm;
    if (pacePerKm > 60 || pacePerKm < 3) return "--'--\"";
    final min = pacePerKm.floor();
    final sec = ((pacePerKm - min) * 60).round();
    return "$min'${sec.toString().padLeft(2, '0')}\"";
  }

  /// Formatted duration string
  String get formattedDuration {
    final hours = _duration.inHours;
    final minutes = _duration.inMinutes.remainder(60);
    final seconds = _duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _tickerTimer?.cancel();
    super.dispose();
  }
}
