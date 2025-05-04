// lib/screens/help_support_screen.dart
import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Contact Support'),
              subtitle: const Text('Get help from our team'),
              onTap: () {
                // Open email client or support form
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.question_answer_outlined),
              title: const Text('FAQs'),
              subtitle: const Text('Frequently asked questions'),
              onTap: () {
                // Show FAQs
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Video Tutorials'),
              subtitle: const Text('Learn how to use the app'),
              onTap: () {
                // Show video tutorials
              },
            ),
          ),
        ],
      ),
    );
  }
}