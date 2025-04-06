// lib/screens/settings_screen.dart
import 'package:fitness_tracker_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, mode, _) {
          final isDark = mode == ThemeMode.dark;

          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeModeNotifier.value =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // Update notifications logic
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
