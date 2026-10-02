import 'package:flutter/material.dart';
import '../models/walk_session.dart';
import '../services/storage_service.dart';
import '../services/tracking_service.dart';
import '../theme/app_colors.dart';
import '../widgets/calm_button.dart';
import '../widgets/weight_dialog.dart';
import 'active_walk_screen.dart';
import 'walk_summary_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final TrackingService trackingService;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.trackingService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Prompt for weight on first launch if not configured yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.storageService.hasSavedWeight) {
        _showWeightDialog();
      }
    });
  }

  void _showWeightDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => WeightDialog(
        storageService: widget.storageService,
        onSaved: () => setState(() {}),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning 🌱";
    } else if (hour < 17) {
      return "Peaceful afternoon 🍃";
    } else {
      return "Tranquil evening ✨";
    }
  }

  Future<void> _startWalk() async {
    // If weight isn't configured, prompt first
    if (!widget.storageService.hasSavedWeight) {
      _showWeightDialog();
      return;
    }

    // Start tracking GPS
    final started = await widget.trackingService.startWalk(
      userWeightKg: widget.storageService.weightKg,
    );

    if (started && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ActiveWalkScreen(
            trackingService: widget.trackingService,
            storageService: widget.storageService,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Location permission is needed to measure distance while you walk.",
          ),
          backgroundColor: AppColors.primary,
          action: SnackBarAction(
            label: "Retry",
            textColor: Colors.white,
            onPressed: _startWalk,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pastWalks = widget.storageService.getPastWalks();
    final weightStr = "${widget.storageService.displayWeight.round()} ${widget.storageService.weightUnit}";

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar with App Name and Weight Chip
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.directions_walk_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "WalkMate",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              "Mindful Walking Companion",
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Weight Chip
                    InkWell(
                      onTap: _showWeightDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monitor_weight_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              weightStr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Greeting and Calming Hero Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "No routes or destinations needed. Just step outside and walk at your own natural pace.",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Big Serene "Start Walk" Action Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: AppColors.sageGradient,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Ready for a stroll?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Track distance, time, and gentle calories with total privacy.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Big Start Circle Button
                      GestureDetector(
                        onTap: _startWalk,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Tap to Start Walk",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Privacy Assurance Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "100% Private Walk Companion",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Location is used only while you walk. No routes, maps, or coordinates are ever stored or uploaded.",
                              style: TextStyle(
                                fontSize: 11,
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
              ),
            ),

            // Lifetime Gentle Stats Summary
            if (widget.storageService.totalLifetimeWalks > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          label: "Walks",
                          value: widget.storageService.totalLifetimeWalks.toString(),
                          emoji: "👟",
                        ),
                        _buildSummaryDivider(),
                        _buildSummaryItem(
                          label: "Total Distance",
                          value: "${widget.storageService.totalLifetimeDistanceKm.toStringAsFixed(1)} km",
                          emoji: "🌱",
                        ),
                        _buildSummaryDivider(),
                        _buildSummaryItem(
                          label: "Calories",
                          value: "${widget.storageService.totalLifetimeCalories.round()} kcal",
                          emoji: "🔥",
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Past Walk Memories Section
            if (pastWalks.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Text(
                    "Recent Walk Memories",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final walk = pastWalks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPastWalkCard(walk),
                      );
                    },
                    childCount: pastWalks.take(5).length,
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({required String label, required String value, required String emoji}) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.divider,
    );
  }

  Widget _buildPastWalkCard(WalkSession walk) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WalkSummaryScreen(
                session: walk,
                storageService: widget.storageService,
                isHistoricalView: true,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.spa_outlined, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${walk.distanceKm.toStringAsFixed(2)} km Mindful Walk",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${walk.formattedDuration} • ${walk.caloriesBurned.round()} kcal • ${walk.encouragingPhrase}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
