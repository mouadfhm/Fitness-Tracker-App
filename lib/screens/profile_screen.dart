// lib/screens/profile_screen.dart
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_tracker_app/providers/profile_provider.dart';
import 'package:fitness_tracker_app/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'update_profile_screen.dart';
import 'home_screen.dart';
import 'workout/workout_calendar_screen.dart';
import 'foods_screen.dart';
import 'progress_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'achievements_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _currentIndex = 3;
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Fetch profile data using the provider after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    setState(() {});
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return;

    final routes = [
      const HomeScreen(),
      const WorkoutCalendarScreen(),
      const FoodsScreen(),
      const ProfileScreen(),
    ];

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => routes[index]));
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

  void _goToAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
    );
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _goToHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
    );
  }

  Future<void> _selectProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Update profile picture through provider
        Provider.of<ProfileProvider>(
          context,
          listen: false,
        ).updateProfilePicture(image.path);
      }
    } catch (e) {
      // Show error dialog if image picking fails
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text(
              'Failed to select image. Please try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _logout() async {
    await _apiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _showLogoutConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text(
            'Are you sure you want to log out of your account?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  void _launchPrivacyPolicy() async {
    // const url = 'https://yourapp.com/privacy-policy';
    // if (await canLaunch(url)) {
    //   await launch(url);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _goToSettings,
            icon: Icon(Icons.settings, color: colorScheme.onSurface),
            tooltip: 'Settings',
          ),
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              // Only show edit button when profile data exists.
              return IconButton(
                onPressed: provider.profileData != null
                    ? () => _goToProfileEdit(provider.profileData!)
                    : null,
                icon: Icon(Icons.edit, color: colorScheme.onSurface),
                tooltip: 'Edit Profile',
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: _buildProfileContent(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildProfileContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator(
            color: colorScheme.primary,
          ));
        } else if (provider.profileData != null) {
          final profileData = provider.profileData!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Avatar with edit option
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 3,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: _selectProfileImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: profileData['custom_profile_pic'] != null
                              ? FileImage(
                                  File(profileData['custom_profile_pic']),
                                )
                              : AssetImage(
                                  profileData['gender'] == "male"
                                      ? profileData['weight'] > 100
                                          ? 'lib/assets/gorilla.png'
                                          : 'lib/assets/dog.png'
                                      : profileData['weight'] > 80
                                          ? 'lib/assets/penguin.png'
                                          : 'lib/assets/rabbit.png',
                                ) as ImageProvider,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                        onPressed: _selectProfileImage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Profile Name
                Text(
                  profileData['name'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  profileData['email'],
                  style: TextStyle(
                    fontSize: 16, 
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                // Membership badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? colorScheme.primary.withOpacity(0.2)
                        : Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode
                          ? colorScheme.primary
                          : Colors.blue[300]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    profileData['membership_type'] ?? 'Free Member',
                    style: TextStyle(
                      color: isDarkMode ? colorScheme.primary : Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Profile Information Cards
                Card(
                  elevation: 3,
                  color: colorScheme.surface,
                  shadowColor: isDarkMode ? Colors.black : Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDarkMode
                          ? colorScheme.onSurface.withOpacity(0.1)
                          : Colors.transparent,
                      width: 1,
                    ),
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
                const SizedBox(height: 20),
                // Quick Action Buttons
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildQuickActionButton(
                      Icons.fitness_center,
                      "Progress",
                      _goToProgressScreen,
                    ),
                    _buildQuickActionButton(
                      Icons.emoji_events,
                      "Achievements",
                      _goToAchievements,
                    ),
                    _buildQuickActionButton(
                      Icons.settings,
                      "Settings",
                      _goToSettings,
                    ),
                    _buildQuickActionButton(
                      Icons.help_outline,
                      "Help",
                      _goToHelpSupport,
                    ),
                    _buildQuickActionButton(
                      Icons.privacy_tip_outlined,
                      "Privacy",
                      _launchPrivacyPolicy,
                    ),
                    _buildQuickActionButton(
                      Icons.logout,
                      "Logout",
                      _showLogoutConfirmation,
                      isLogout: true,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // App Version
                Text(
                  "App version: 1.2.3",
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Error: ${provider.errorMessage}",
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<ProfileProvider>(
                      context,
                      listen: false,
                    ).fetchProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // Helper UI Builders
  Widget _buildProfileTile(IconData icon, String title, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    Color bgColor;
    Color iconTextColor;
    
    if (isLogout) {
      bgColor = isDarkMode
          ? Colors.red.withOpacity(0.2)
          : Colors.red[100]!;
      iconTextColor = Colors.red;
    } else {
      bgColor = isDarkMode
          ? colorScheme.primary.withOpacity(0.15)
          : colorScheme.primary.withOpacity(0.1);
      iconTextColor = colorScheme.primary;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode
                ? iconTextColor.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconTextColor, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: iconTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}