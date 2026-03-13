import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'home_page.dart';
import 'settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await _initUserId();
  await _lockAndroidOrientationToPortrait();
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameUPCModel(),
      child: const MyApp()),
  );
}

Future<void> _initUserId() async {
  const storage = FlutterSecureStorage();
  final gameUpcUserId = await storage.read(key: Settings.gameUpcUserIdKey);

  if (gameUpcUserId == null) {
    final uuid = const Uuid().v4();
    await storage.write(key: Settings.gameUpcUserIdKey, value: uuid);
    debugPrint('Generated new game_upc_user_id: $uuid');
  } else {
    debugPrint('Existing game_upc_user_id: ${gameUpcUserId}');
  }
}

Future<void> _lockAndroidOrientationToPortrait() async {
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
