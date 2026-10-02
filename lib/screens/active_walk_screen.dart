import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/tracking_service.dart';
import '../theme/app_colors.dart';
import '../widgets/milestone_banner.dart';
import '../widgets/pulse_circle.dart';
import '../widgets/stat_badge.dart';
import 'walk_summary_screen.dart';

class ActiveWalkScreen extends StatefulWidget {
  final TrackingService trackingService;
  final StorageService storageService;

  const ActiveWalkScreen({
    super.key,
    required this.trackingService,
    required this.storageService,
  });

  @override
  State<ActiveWalkScreen> createState() => _ActiveWalkScreenState();
}

class _ActiveWalkScreenState extends State<ActiveWalkScreen> {
  @override
  void initState() {
    super.initState();
    widget.trackingService.addListener(_onTrackerUpdate);
  }

  @override
  void dispose() {
    widget.trackingService.removeListener(_onTrackerUpdate);
    super.dispose();
  }

  void _onTrackerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _togglePause() {
    if (widget.trackingService.isTracking) {
      widget.trackingService.pauseWalk();
    } else {
      widget.trackingService.resumeWalk();
    }
  }

  Future<void> _stopWalk() async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.park_outlined, color: AppColors.primary, size: 24),
            SizedBox(width: 10),
            Text(
              "Finish Your Walk?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        content: const Text(
          "We'll wrap up your session and create a beautiful memory card celebrating your movement.",
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Keep Walking", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Finish Walk"),
          ),
        ],
      ),
    );

    if (shouldStop == true && mounted) {
      final session = widget.trackingService.stopWalk();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WalkSummaryScreen(
            session: session,
            storageService: widget.storageService,
            isHistoricalView: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final distanceKm = widget.trackingService.cumulativeDistanceKm;
    final currentSpeed = widget.trackingService.currentSpeedKmh;
    final durationStr = widget.trackingService.formattedDuration;
    final calories = widget.trackingService.caloriesBurned;
    final paceStr = widget.trackingService.formattedPace;
    final isPaused = widget.trackingService.isPaused;
    final milestone = widget.trackingService.latestMilestone;
    final insight = widget.trackingService.currentInsight;

    return WillPopScope(
      onWillPop: () async {
        // Prevent accidental back exit while tracking
        _stopWalk();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isPaused ? AppColors.accentAmberSoft : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPaused ? AppColors.accentAmber : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isPaused ? "Walk Paused • Resting" : "Active Walk • Mindful Pace",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPaused ? AppColors.accentAmber : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
              onPressed: _stopWalk,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 500m Milestone Celebration Banner (pops up if milestone triggered)
              if (milestone != null)
                MilestoneBanner(
                  milestone: milestone,
                  onDismiss: widget.trackingService.dismissMilestone,
                ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // Center Breathing Pulse Circle with Primary Distance
                        PulseCircle(
                          isPaused: isPaused,
                          size: 210,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                distanceKm.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                  letterSpacing: -1.5,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "kilometers",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  paceStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Secondary Stats 2x2 Grid
                        Row(
                          children: [
                            Expanded(
                              child: StatBadge(
                                icon: Icons.timer_outlined,
                                label: "Duration",
                                value: durationStr,
                                iconColor: AppColors.accentPeach,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatBadge(
                                icon: Icons.speed_rounded,
                                label: "Current Speed",
                                value: currentSpeed.toStringAsFixed(1),
                                unit: "km/h",
                                iconColor: AppColors.accentTeal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatBadge(
                                icon: Icons.local_fire_department_rounded,
                                label: "Est. Calories",
                                value: calories.round().toString(),
                                unit: "kcal",
                                iconColor: AppColors.accentAmber,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatBadge(
                                icon: Icons.straighten_rounded,
                                label: "Meters",
                                value: widget.trackingService.cumulativeDistanceMeters.round().toString(),
                                unit: "m",
                                iconColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Movement & Calorie Gentle Insight Bubble
                        if (insight != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWarm,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(insight.iconEmoji, style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        insight.title,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        insight.description,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Walk Action Controls
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Pause / Resume Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _togglePause,
                        icon: Icon(
                          isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          color: AppColors.textDark,
                        ),
                        label: Text(
                          isPaused ? "Resume" : "Pause",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.divider, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Stop Walk Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _stopWalk,
                        icon: const Icon(Icons.stop_rounded, color: Colors.white),
                        label: const Text(
                          "Finish Walk",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
