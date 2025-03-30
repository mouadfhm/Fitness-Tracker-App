// lib/screens/profile_screen.dart
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_tracker_app/providers/profile_provider.dart';
import 'package:fitness_tracker_app/services/api_service.dart'; // New import
import 'package:image_picker/image_picker.dart'; // New import for image selection
import 'update_profile_screen.dart';
import 'home_screen.dart';
import 'workout/workout_calendar_screen.dart';
import 'foods_screen.dart';
import 'progress_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'settings_screen.dart'; // New import
import 'help_support_screen.dart'; // New import
import 'achievements_screen.dart'; // New import
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final int _currentIndex = 3;
  late TabController _tabController;
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Fetch profile data using the provider after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
      _loadSettings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
    });
  }


  void _onNavBarTap(int index) {
    if (index == _currentIndex) return;

    final routes = [
      const HomeScreen(),
      const WorkoutCalendarScreen(),
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
          builder:
              (context) => AlertDialog(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _goToSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Profile"),
            // Tab(text: "Stats"),
            Tab(text: "Activity"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildProfileTab(),  _buildActivityTab()],
        // children: [_buildProfileTab(), _buildStatsTab(), _buildActivityTab()],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildProfileTab() {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
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
                    GestureDetector(
                      onTap: _selectProfileImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            profileData['custom_profile_pic'] != null
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
                                    )
                                    as ImageProvider,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  profileData['email'],
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                // Membership badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profileData['membership_type'] ?? 'Free Member',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                      color: Colors.red[100],
                      iconColor: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // App Version
                Text(
                  "App version: 1.2.3",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<ProfileProvider>(
                      context,
                      listen: false,
                    ).fetchProfile();
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // Widget _buildStatsTab() {
  //   return Consumer<ProfileProvider>(
  //     builder: (context, provider, child) {
  //       if (provider.isLoading) {
  //         return const Center(child: CircularProgressIndicator());
  //       } else if (provider.profileData != null) {
  //         return SingleChildScrollView(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 "Your Fitness Stats",
  //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //               ),
  //               const SizedBox(height: 16),
  //               // BMI Card
  //               _buildStatsCard(
  //                 "BMI",
  //                 _calculateBMI(
  //                   (provider.profileData!['weight'] as num).toDouble(),
  //                   (provider.profileData!['height'] as num).toDouble(),
  //                 ).toStringAsFixed(1),
  //                 _getBMICategory(
  //                   _calculateBMI(
  //                     (provider.profileData!['weight'] as num).toDouble(),
  //                     (provider.profileData!['height'] as num).toDouble(),
  //                   ),
  //                 ),
  //                 Icons.health_and_safety,
  //                 _getBMIColor(
  //                   _calculateBMI(
  //                     (provider.profileData!['weight'] as num).toDouble(),
  //                     (provider.profileData!['height'] as num).toDouble(),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               // Weekly Summary
  //               const Text(
  //                 "Weekly Summary",
  //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //               ),
  //               const SizedBox(height: 8),
  //               // Summary Stats
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: _buildStatItem(
  //                       "Workouts",
  //                       "12",
  //                       Icons.fitness_center,
  //                       Colors.orange,
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: _buildStatItem(
  //                       "Calories",
  //                       "8,540",
  //                       Icons.local_fire_department,
  //                       Colors.red,
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: _buildStatItem(
  //                       "Steps",
  //                       "58,423",
  //                       Icons.directions_walk,
  //                       Colors.green,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 24),
  //               // Goals Progress
  //               const Text(
  //                 "Goals Progress",
  //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //               ),
  //               const SizedBox(height: 16),
  //               _buildProgressBar(
  //                 "Weight Goal",
  //                 "${provider.profileData!['weight']} kg",
  //                 "${provider.profileData!['target_weight'] ?? (provider.profileData!['weight'] - 5)} kg",
  //                 0.6,
  //               ),
  //               const SizedBox(height: 12),
  //               _buildProgressBar(
  //                 "Workout Frequency",
  //                 "3 days/week",
  //                 "5 days/week",
  //                 0.6,
  //               ),
  //               const SizedBox(height: 12),
  //               _buildProgressBar(
  //                 "Daily Steps",
  //                 "8,340 steps",
  //                 "10,000 steps",
  //                 0.83,
  //               ),
  //               const SizedBox(height: 24),
  //               Center(
  //                 child: ElevatedButton.icon(
  //                   onPressed: _goToProgressScreen,
  //                   icon: const Icon(Icons.analytics),
  //                   label: const Text("View Detailed Stats"),
  //                   style: ElevatedButton.styleFrom(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 24,
  //                       vertical: 12,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       } else {
  //         return Center(
  //           child: Text(
  //             "Error: ${provider.errorMessage}",
  //             style: const TextStyle(color: Colors.red, fontSize: 16),
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }

  Widget _buildActivityTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          "Completed Workout",
          "Upper Body Strength",
          "Today, 9:30 AM",
          Icons.fitness_center,
          Colors.blue,
        ),
        _buildActivityItem(
          "Tracked Meal",
          "Lunch - 650 calories",
          "Today, 12:15 PM",
          Icons.restaurant,
          Colors.orange,
        ),
        _buildActivityItem(
          "Achieved Badge",
          "10 Day Streak",
          "Yesterday",
          Icons.emoji_events,
          Colors.amber,
        ),
        _buildActivityItem(
          "Completed Workout",
          "Morning Run - 5km",
          "Yesterday, 7:45 AM",
          Icons.directions_run,
          Colors.green,
        ),
        _buildActivityItem(
          "Updated Weight",
          "75.5 kg",
          "2 days ago",
          Icons.monitor_weight,
          Colors.purple,
        ),
        _buildActivityItem(
          "Completed Workout",
          "Full Body HIIT",
          "3 days ago",
          Icons.fitness_center,
          Colors.blue,
        ),
        _buildActivityItem(
          "Added Friend",
          "Connected with Jane",
          "3 days ago",
          Icons.person_add,
          Colors.teal,
        ),
        Center(
          child: TextButton(
            onPressed: () {
              // View more activity
            },
            child: const Text("View More Activity"),
          ),
        ),
      ],
    );
  }

  // Helper Functions


  // Helper UI Builders

  Widget _buildProfileTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value, style: TextStyle(color: Colors.grey[700])),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color ?? Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor ?? Colors.blue, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: iconColor ?? Colors.blue[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ),
    );
  }
}
