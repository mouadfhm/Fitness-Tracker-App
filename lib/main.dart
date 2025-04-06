import 'package:fitness_tracker_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/token_service.dart';
import 'providers/food_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/achievement_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // Load the environment file - change the filename based on your build environment
  await dotenv.load(fileName: ".env.production");
  // await dotenv.load(fileName: ".env.development");

  // Get the stored token (if any)
  final token = await TokenService.getToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileProvider()..fetchProfile(),
        ),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => ExercisesProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),

        // You can add more providers here if needed
      ],
      child: MyApp(isLoggedIn: token != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeModeNotifier,
      builder: (context, ThemeMode mode, _) {
        return MaterialApp(
          title: 'Fitness Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
          darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
          themeMode: mode,
          home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
        );
      },
    );
  }
  }