class MovementInsight {
  final String title;
  final String description;
  final String category; // 'movement', 'calories', 'rest', 'mindfulness'
  final String iconEmoji;

  MovementInsight({
    required this.title,
    required this.description,
    required this.category,
    required this.iconEmoji,
  });

  static List<MovementInsight> defaultInsights = [
    MovementInsight(
      title: "Mind Clearing",
      description: "A gentle walking pace stimulates blood flow to the hippocampus, boosting creative problem solving.",
      category: "mindfulness",
      iconEmoji: "🌿",
    ),
    MovementInsight(
      title: "Gentle Metabolism",
      description: "Walking activates slow-twitch muscle fibers, which burn lipids steadily without straining joints.",
      category: "calories",
      iconEmoji: "🌱",
    ),
    MovementInsight(
      title: "Resting Harmony",
      description: "Taking a short pause regulates heart rate recovery and resets breathing cadence.",
      category: "rest",
      iconEmoji: "🍃",
    ),
    MovementInsight(
      title: "Post-Walk Glow",
      description: "Just 20 minutes of continuous movement releases gentle mood-elevating neurotransmitters.",
      category: "movement",
      iconEmoji: "✨",
    ),
    MovementInsight(
      title: "Cellular Energy",
      description: "Every 50 kcal burned powers the equivalent of an hour of uninterrupted cognitive focus.",
      category: "calories",
      iconEmoji: "🔋",
    ),
    MovementInsight(
      title: "Spine & Posture",
      description: "Walking naturally aligns spinal discs and releases tightness accumulated from sitting.",
      category: "movement",
      iconEmoji: "🚶",
    ),
  ];
}
