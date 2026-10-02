# WalkMate 🌱 - Supportive Walking Companion

WalkMate is a calm, modern, and supportive Android walking companion built with Flutter. It helps you stay mindfully active without the noise of competitive fitness apps, leaderboards, or social feeds.

---

## ✨ Features

- **One-time Weight Entry**: Input your weight once (in kg or lbs), stored safely on your phone only. Used strictly for a scientifically sound MET-based calorie estimate.
- **Start Walk with Temporary GPS**:
  - Distance is cumulative—no pre-planned route, maps, or destination required.
  - Real-time metrics: Cumulative distance, current speed (km/h), duration timer, and estimated calories burned.
  - High-accuracy GPS with speed filtering (ignores stationary jitter and teleports).
- **MET-Based Calorie Estimation**:
  - Dynamically calculates energy expenditure using the standard Compendium of Physical Activities formula:
    $$\text{Calories / min} = \frac{\text{MET} \times 3.5 \times \text{Weight (kg)}}{200}$$
  - Adapts MET automatically to walking intensity (2.0 for strolling up to 5.0 for power walking, 1.2 for resting pauses).
- **500m Milestone Cheers**:
  - Supportive, non-judgmental cheer every 500 meters (e.g., *"0.5 km done 🌱 Nice start. Every journey begins with a single peaceful step"*).
  - Gentle movement and calorie insights during milestones or rest periods.
- **Stop Walk & Walk Summary**:
  - Summarizes final distance, total duration, calories burned, average speed, and pace.
- **Memory Photo & Walk Card**:
  - Take a photo with the Camera or select from Gallery.
  - Choose an encouraging phrase or write a personal reflection.
  - Automatically generates a high-resolution, shareable/downloadable Japanese editorial Polaroid-style Walk Memory Card.
  - Native Android share sheet integration (`share_plus`) and local download.

---

## 🔒 Privacy First

- **Location is used strictly in real-time** during an active walk to compute distance delta.
- **Zero GPS coordinates or route history** are stored in memory or on disk. Once a distance delta is calculated, raw coordinates are discarded immediately.
- **No backend, no accounts, no cloud sync, no tracking SDKs.** Everything stays 100% on your device.

---

## 📱 How to Run & Test on a Physical Android Device

### Prerequisites
1. Android phone running Android 7.0+ (API 24+)
2. USB cable or Wireless Debugging connection
3. Flutter SDK & Android SDK

### Steps to Connect Your Android Phone:
1. **Enable Developer Options on your phone**:
   - Go to **Settings** > **About Phone**.
   - Tap **Build Number** 7 times until you see *"You are now a developer!"*.
2. **Enable USB Debugging**:
   - Go to **Settings** > **System** > **Developer Options**.
   - Turn on **USB Debugging**.
3. **Connect to your PC**:
   - Plug in your phone via USB.
   - Accept the prompt on your phone screen: *"Allow USB debugging from this computer?"*
4. **Verify the connection**:
   ```bash
   adb devices
   ```
   You should see your phone listed with a device serial.

### Run the App:
```bash
# Get packages
flutter pub get

# Run on your connected Android device
flutter run -d <your-device-id>
```

### Build Release APK:
```bash
flutter build apk --release
```
The installable APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📂 Project Architecture

```
Runwithme/
├── android/                   # Android native configuration & manifests
│   ├── app/src/main/AndroidManifest.xml  # GPS, Camera & Notification permissions
│   └── app/build.gradle
├── lib/
│   ├── main.dart              # App bootstrap and service initialization
│   ├── models/
│   │   ├── walk_session.dart      # Aggregate summary model (zero GPS tracks stored)
│   │   ├── milestone_info.dart    # 500m milestone definition & phrases
│   │   └── movement_insight.dart  # Calorie & mindfulness insights
│   ├── services/
│   │   ├── storage_service.dart   # SharedPreferences persistence (weight, totals)
│   │   ├── calorie_service.dart   # MET-based formula using weight, speed & time
│   │   ├── tracking_service.dart  # Temporary GPS stream & distance accumulator
│   │   ├── milestone_service.dart # 500m trigger logic and cheers
│   │   └── memory_card_service.dart # RepaintBoundary PNG capture & native sharing
│   ├── theme/
│   │   ├── app_colors.dart        # Calming botanical sage & soft oat palette
│   │   └── app_theme.dart         # Material 3 typography & rounded surfaces
│   ├── widgets/
│   │   ├── calm_button.dart       # Tactile, pill-shaped buttons
│   │   ├── stat_badge.dart        # Clean metric display cards
│   │   ├── pulse_circle.dart      # Breathing halo animation for active walk
│   │   ├── milestone_banner.dart  # Celebratory 500m popup
│   │   ├── weight_dialog.dart     # Weight picker dialog with kg/lbs toggle
│   │   └── walk_memory_card.dart  # Editorial Polaroid memory card
│   └── screens/
│       ├── home_screen.dart       # Welcoming dashboard, start button, privacy banner
│       ├── active_walk_screen.dart# Real-time metrics & breathing pulse
│       └── walk_summary_screen.dart # Memory card generator & share sheet
├── test/
│   ├── calorie_service_test.dart  # Unit tests for MET formulas
│   ├── milestone_service_test.dart# Unit tests for 500m boundaries
│   └── walk_session_test.dart     # Unit tests for model & privacy guarantees
└── pubspec.yaml               # Flutter package configuration
```
