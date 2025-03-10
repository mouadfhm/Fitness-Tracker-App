// lib/screens/profile_screen.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_tracker_app/providers/profile_provider.dart';
import 'update_profile_screen.dart';
import 'home_screen.dart';
import 'workout_screen.dart';
import 'foods_screen.dart';
import 'progress_screen.dart';
import 'widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    // Fetch profile data using the provider after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return;

    final routes = [
      const HomeScreen(),
      const WorkoutScreen(),
      const FoodsScreen(),
      const ProfileScreen(),
    ];

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => routes[index]));
  }

  void _goToProfileEdit(Map<String, dynamic> profileData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateProfileScreen(profileData: profileData),
      ),
    );
  }

  void _goToProgressScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProgressScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              // Only show edit button when profile data exists.
              return IconButton(
                onPressed:
                    provider.profileData != null
                        ? () => _goToProfileEdit(provider.profileData!)
                        : null,
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Profile',
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.profileData != null) {
            final profileData = provider.profileData!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        profileData['gender'] == "male"
                            ? profileData['weight'] > 100
                                ? 'lib/assets/gorilla.png' // For males > 100kg
                                : 'lib/assets/dog.png' // For males <= 100kg
                            : profileData['weight'] > 80
                            ? 'lib/assets/penguin.png' // For females > 80kg
                            : 'lib/assets/rabbit.png', // For females <= 80kg
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Profile Name
                  Text(
                    profileData['name'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    profileData['email'],
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  // Profile Information Cards
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildProfileTile(
                          Icons.cake,
                          "Age",
                          "${profileData['age']} years",
                        ),
                        _buildProfileTile(
                          Icons.monitor_weight,
                          "Weight",
                          "${profileData['weight']} kg",
                        ),
                        _buildProfileTile(
                          Icons.height,
                          "Height",
                          "${profileData['height']} cm",
                        ),
                        _buildProfileTile(
                          Icons.fitness_center,
                          "Activity Level",
                          profileData['activity_level'],
                        ),
                        _buildProfileTile(
                          Icons.emoji_events,
                          "Fitness Goal",
                          profileData['fitness_goal'],
                        ),
                        _buildProfileTile(
                          profileData['gender'] == "male"
                              ? Icons.male
                              : Icons.female,
                          "Gender",
                          profileData['gender'],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                "Error: ${provider.errorMessage}",
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToProgressScreen,
        icon: const Icon(Icons.fitness_center),
        label: const Text("Progress"),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  // Helper function to build Profile Info Tiles
  Widget _buildProfileTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value, style: TextStyle(color: Colors.grey[700])),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
