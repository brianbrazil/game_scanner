import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'home_page.dart';
import 'settings.dart';

Future<void> _initUserId() async {
  final prefs = await SharedPreferences.getInstance();
  const key = Settings.prefsGameUpcUserId;

  if (prefs.getString(key) == null) {
    final uuid = const Uuid().v4();
    await prefs.setString(key, uuid);
    debugPrint('Generated new game_upc_user_id: $uuid');
  } else {
    debugPrint('Existing game_upc_user_id: ${prefs.getString(key)}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initUserId();
  await dotenv.load(fileName: ".env");
  // Lock orientation to portrait on Android phones only (leave Android tablets free)
  if (Platform.isAndroid) {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final logicalSize = view.physicalSize / view.devicePixelRatio;
    final shortestSide = math.min(logicalSize.width, logicalSize.height);
    final isTablet = shortestSide >= 600; // common heuristic
    if (!isTablet) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameUPCModel(),
      child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initUserId() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'user_id';

    if (prefs.getString(key) == null) {
      final uuid = const Uuid().v4();
      await prefs.setString(key, uuid);
      debugPrint('Generated new user_id: $uuid');
    } else {
      debugPrint('Existing user_id: ${prefs.getString(key)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // Or use theme color:
          foregroundColor: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.lightBlue, // This will apply to standard Icons
        ),
      ),
      home: HomePage(),
    );
  }
}
