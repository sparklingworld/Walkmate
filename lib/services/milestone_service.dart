import '../models/milestone_info.dart';
import '../models/movement_insight.dart';

/// Manages supportive milestones every 500 meters (0.5 km)
/// and provides gentle calorie and movement insights.
class MilestoneService {
  /// Supportive milestone configurations for each 500m interval.
  static final Map<int, _MilestoneContent> _milestoneTemplates = {
    500: _MilestoneContent(
      title: "0.5 km done 🌱",
      message: "Nice start! Taking the first step is often the hardest, and you did it.",
      insight: "Your breathing and heart are settling into a warm, natural stride.",
      emoji: "🌱",
    ),
    1000: _MilestoneContent(
      title: "1.0 km achieved 🌿",
      message: "A full kilometer! Feel the ground supporting every step you take.",
      insight: "Circulation is gently improving, bringing fresh oxygen to your mind.",
      emoji: "🌿",
    ),
    1500: _MilestoneContent(
      title: "1.5 km unlocked 🍃",
      message: "You've settled into a lovely rhythm. Notice the world around you.",
      insight: "Your shoulders and neck naturally drop tension as you keep moving.",
      emoji: "🍃",
    ),
    2000: _MilestoneContent(
      title: "2.0 km reached ✨",
      message: "Two kilometers of pure self-care. Notice how your thoughts clear.",
      insight: "Burned ~100 kcal: like recharging your brain's internal focus battery.",
      emoji: "✨",
    ),
    2500: _MilestoneContent(
      title: "2.5 km milestone 🌸",
      message: "Halfway to five! Walk at your own gentle pace—there's no rush.",
      insight: "Movement boosts serotonin, providing a steady feeling of calm.",
      emoji: "🌸",
    ),
    3000: _MilestoneContent(
      title: "3.0 km passed 🌾",
      message: "Three full kilometers. Beautiful dedication to your well-being.",
      insight: "Your leg muscles and core are happily engaging without strain.",
      emoji: "🌾",
    ),
    3500: _MilestoneContent(
      title: "3.5 km done 🕊️",
      message: "Floating through steps. Be proud of taking this time for yourself.",
      insight: "Fresh air and steady movement enhance your quality of sleep tonight.",
      emoji: "🕊️",
    ),
    4000: _MilestoneContent(
      title: "4.0 km completed 🌲",
      message: "Four kilometers! Over 5,000 gentle, mindful footprints left behind.",
      insight: "Your cardiovascular system is thanking you for this steady endurance.",
      emoji: "🌲",
    ),
    4500: _MilestoneContent(
      title: "4.5 km reached 🌻",
      message: "Almost at five kilometers. Breathe in deep tranquility.",
      insight: "Endorphins are gently peaking, creating that post-walk peaceful glow.",
      emoji: "🌻",
    ),
    5000: _MilestoneContent(
      title: "5.0 km champion 🌟",
      message: "Five whole kilometers of peaceful walking! Celebrate this moment.",
      insight: "You've given your heart, mind, and spirit a wonderful, lasting gift.",
      emoji: "🌟",
    ),
  };

  /// Returns MilestoneInfo if current cumulative distance has just reached a 500m boundary.
  static MilestoneInfo? checkMilestone({
    required double currentDistanceMeters,
    required double previousDistanceMeters,
  }) {
    final prevMilestoneIndex = (previousDistanceMeters / 500.0).floor();
    final curMilestoneIndex = (currentDistanceMeters / 500.0).floor();

    if (curMilestoneIndex > prevMilestoneIndex && curMilestoneIndex > 0) {
      final milestoneMeters = curMilestoneIndex * 500.0;
      final template = _milestoneTemplates[milestoneMeters.toInt()];

      if (template != null) {
        return MilestoneInfo(
          milestoneIndex: curMilestoneIndex,
          distanceMeters: milestoneMeters,
          title: template.title,
          message: template.message,
          insight: template.insight,
          emoji: template.emoji,
        );
      } else {
        // Beyond 5000m
        final km = (milestoneMeters / 1000.0).toStringAsFixed(1);
        return MilestoneInfo(
          milestoneIndex: curMilestoneIndex,
          distanceMeters: milestoneMeters,
          title: "$km km done 🌱",
          message: "Continuing strong with grace and care. Keep listening to your body.",
          insight: "Every step continues to support your vitality and inner calm.",
          emoji: "🌱",
        );
      }
    }
    return null;
  }

  /// Supportive insights to show when user pauses or rests
  static final List<MovementInsight> restInsights = [
    MovementInsight(
      title: "Restful Pause",
      description: "Taking a breather helps lower cortisol and regulates your pulse back to normal.",
      category: "rest",
      iconEmoji: "🍵",
    ),
    MovementInsight(
      title: "Hydration Moment",
      description: "A small sip of water now keeps your cells hydrated and muscles supple.",
      category: "rest",
      iconEmoji: "💧",
    ),
    MovementInsight(
      title: "Take a Deep Breath",
      description: "Inhale the freshness around you. Savor this pause before stepping forward.",
      category: "rest",
      iconEmoji: "🍃",
    ),
  ];

  static MovementInsight getRestInsight(int index) {
    return restInsights[index % restInsights.length];
  }
}

class _MilestoneContent {
  final String title;
  final String message;
  final String insight;
  final String emoji;

  _MilestoneContent({
    required this.title,
    required this.message,
    required this.insight,
    required this.emoji,
  });
}
