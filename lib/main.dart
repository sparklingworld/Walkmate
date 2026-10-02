import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/tracking_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for a comfortable walking grip
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style with transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize local persistent storage
  final storageService = await StorageService.init();
  final trackingService = TrackingService();

  runApp(WalkMateApp(
    storageService: storageService,
    trackingService: trackingService,
  ));
}

class WalkMateApp extends StatelessWidget {
  final StorageService storageService;
  final TrackingService trackingService;

  const WalkMateApp({
    super.key,
    required this.storageService,
    required this.trackingService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WalkMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomeScreen(
        storageService: storageService,
        trackingService: trackingService,
      ),
    );
  }
}
