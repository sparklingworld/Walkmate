import 'package:flutter/material.dart';

/// Calm, modern, and supportive color palette for WalkMate.
/// Inspired by Japanese forest bathing (Shinrin-yoku) and gentle morning walks.
class AppColors {
  // Primary Botanical Sage tones
  static const Color primary = Color(0xFF3E664F); // Deep calming forest sage
  static const Color primaryLight = Color(0xFF5E8B70);
  static const Color primarySoft = Color(0xFFE9F1EC); // Soft mint mist
  static const Color primaryPastel = Color(0xFFD3E4D9);

  // Background and Canvas
  static const Color canvas = Color(0xFFF9FAF8); // Warm porcelain white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceWarm = Color(0xFFF4F1EA); // Soft oat/sand

  // Warm Accents (sunset glow, terracotta blossoms)
  static const Color accentPeach = Color(0xFFE58F65);
  static const Color accentPeachSoft = Color(0xFFFBECE3);
  static const Color accentAmber = Color(0xFFD99B43);
  static const Color accentAmberSoft = Color(0xFFFDF6EA);
  static const Color accentTeal = Color(0xFF4C8583);

  // Text and Neutral hierarchy
  static const Color textDark = Color(0xFF1E2822); // Deep forest charcoal
  static const Color textMuted = Color(0xFF6B7A70); // Olive slate grey
  static const Color textLight = Color(0xFF9CA9A1); // Gentle caption grey
  static const Color divider = Color(0xFFE5EDE7);

  // Status & Milestones
  static const Color milestoneGreen = Color(0xFF4C8B64);
  static const Color milestoneBadge = Color(0xFFE5F4EC);
  static const Color privacyPill = Color(0xFFEEF5F0);

  // Gradients
  static const LinearGradient sageGradient = LinearGradient(
    colors: [Color(0xFF466F57), Color(0xFF385B46)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFBF9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmSunset = LinearGradient(
    colors: [Color(0xFFFCEFE9), Color(0xFFF6F8F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
