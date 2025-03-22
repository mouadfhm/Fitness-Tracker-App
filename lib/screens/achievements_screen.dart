// lib/screens/achievements_screen.dart
import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: 8, // Example count
        itemBuilder: (context, index) {
          final bool unlocked = index < 3; // First 3 are unlocked for example
          
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    unlocked ? Icons.emoji_events : Icons.lock_outline,
                    size: 48,
                    color: unlocked ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    unlocked 
                        ? 'Achievement ${index + 1}' 
                        : 'Locked Achievement',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: unlocked ? Colors.black : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    unlocked 
                        ? 'You earned this badge!' 
                        : 'Complete more workouts to unlock',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}