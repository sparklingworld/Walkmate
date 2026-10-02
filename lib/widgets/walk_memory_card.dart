import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/walk_session.dart';
import '../theme/app_colors.dart';

class WalkMemoryCard extends StatelessWidget {
  final WalkSession session;
  final String encouragingPhrase;
  final String? customNote;
  final File? photoFile;

  const WalkMemoryCard({
    super.key,
    required this.session,
    required this.encouragingPhrase,
    this.customNote,
    this.photoFile,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final dateStr = dateFormat.format(session.endTime);
    final timeStr = timeFormat.format(session.endTime);

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBF9), // Cream paper tone
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFEBE6DC), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header: Date, Time & Leaf icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco_rounded, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          letterSpacing: 0.1,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Walk Memory",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentPeach,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Photo or Artistic Botanical Backdrop
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: _buildPhotoArea(),
            ),
          ),
          const SizedBox(height: 16),

          // Encouraging Phrase Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.format_quote_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    encouragingPhrase,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (customNote != null && customNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "\"${customNote!.trim()}\"",
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEBE6DC), height: 1),
          const SizedBox(height: 16),

          // Walk Stats Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCol(
                value: session.distanceKm.toStringAsFixed(2),
                unit: "km",
                label: "Distance",
                icon: Icons.directions_walk_rounded,
                iconColor: AppColors.primary,
              ),
              _buildStatCol(
                value: session.formattedDuration,
                unit: "",
                label: "Duration",
                icon: Icons.timer_outlined,
                iconColor: AppColors.accentPeach,
              ),
              _buildStatCol(
                value: session.caloriesBurned.round().toString(),
                unit: "kcal",
                label: "Calories",
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.accentAmber,
              ),
              _buildStatCol(
                value: session.averageSpeedKmh.toStringAsFixed(1),
                unit: "km/h",
                label: "Avg Speed",
                icon: Icons.speed_rounded,
                iconColor: AppColors.accentTeal,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Footer signature
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 12, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  const Text(
                    "Private • No GPS saved",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    "WalkMate",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text("🌱", style: TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoArea() {
    if (photoFile != null && photoFile!.existsSync()) {
      return Image.file(
        photoFile!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (session.photoPath != null && File(session.photoPath!).existsSync()) {
      return Image.file(
        File(session.photoPath!),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    // Calming artistic botanical fallback illustration
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF86A789), Color(0xFF436850)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background sun rays / circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.park_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${session.distanceKm.toStringAsFixed(2)} km Mindful Walk",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Nourishing both body and mind",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol({
    required String value,
    required String unit,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(height: 6),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              fontFamily: 'Outfit',
            ),
            children: [
              if (unit.isNotEmpty)
                TextSpan(
                  text: " $unit",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
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
}
