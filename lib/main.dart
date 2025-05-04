// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/food_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/achievement_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/token_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables; switch file as needed (e.g., ".env.production" for production)
  // await dotenv.load(fileName: ".env.development");
  await dotenv.load(fileName: ".env.production");

  // Retrieve any stored token (to determine if the user is logged in)
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
        // Provide the ThemeProvider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
    // Use the ThemeProvider from Provider to get the current theme mode
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        // Customize additional light theme properties here...
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        // Customize additional dark theme properties here...
      ),
      themeMode: themeProvider.themeMode, // Uses the theme mode from ThemeProvider
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
