// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fitness_tracker_app/services/api_service.dart';
import 'update_profile_screen.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'foods_screen.dart';
import 'widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  String errorMessage = '';
  final int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  void _fetchProfile() async {
    try {
      final data = await apiService.getProfile();
      setState(() {
        profileData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _goToProfileEdit() {
    if (profileData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UpdateProfileScreen(profileData: profileData!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : profileData != null
              ? SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Avatar
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                          profileData!['gender'] == "male"
                              ? profileData!['weight'] > 100
                                  ? 'lib/assets/gorilla.png' // Show gorilla for males > 100kg
                                  : 'lib/assets/dog.png' // Show dog for males <= 100kg
                              : profileData!['weight'] > 80
                              ? 'lib/assets/penguin.png' // Show penguin for females > 80kg
                              : 'lib/assets/rabbit.png', // Show rabbit for females <= 80kg
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Profile Name
                    Text(
                      profileData!['name'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      profileData!['email'],
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
                            "${profileData!['age']} years",
                          ),
                          _buildProfileTile(
                            Icons.monitor_weight,
                            "Weight",
                            "${profileData!['weight']} kg",
                          ),
                          _buildProfileTile(
                            Icons.height,
                            "Height",
                            "${profileData!['height']} cm",
                          ),
                          _buildProfileTile(
                            Icons.fitness_center,
                            "Activity Level",
                            profileData!['activity_level'],
                          ),
                          _buildProfileTile(
                            Icons.emoji_events,
                            "Fitness Goal",
                            profileData!['fitness_goal'],
                          ),
                          _buildProfileTile(
                            profileData!['gender'] == "male"
                                ? Icons.male
                                : Icons.female,
                            "Gender",
                            profileData!['gender'],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              : Center(
                child: Text(
                  "Error: $errorMessage",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

      // Floating Button for Editing Profile
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToProfileEdit,
        icon: const Icon(Icons.edit),
        label: const Text("Edit Profile"),
      ),

      // Bottom Navigation
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) {
                  switch (index) {
                    case 0:
                      return const HomeScreen();
                    case 1:
                      return const ProgressScreen();
                    case 2:
                      return const FoodsScreen();
                    case 3:
                    default:
                      return const ProfileScreen();
                  }
                },
              ),
            );
          }
        },
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
