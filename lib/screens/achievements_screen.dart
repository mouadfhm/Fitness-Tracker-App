import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late Future<Map<String, dynamic>> _achievementsData;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _achievementsData = _loadAchievements();
  }

  Future<Map<String, dynamic>> _loadAchievements() async {
    try {
      // Get all achievements and user achievements
      final allAchievements = await _apiService.getAchievements();
      final userAchievements = await _apiService.getUserAchievements();

      // Create a map to easily look up which achievements the user has unlocked
      final Map<int, dynamic> userAchievementsMap = {};
      for (var achievement in userAchievements) {
        userAchievementsMap[achievement['achievement_id']] = achievement;
      }

      return {
        'allAchievements': allAchievements,
        'userAchievementsMap': userAchievementsMap,
      };
    } catch (e) {
      // Re-throw to be caught by the FutureBuilder
      rethrow;
    }
  }

  // Map achievement types to appropriate icons
  IconData getIconForType(String type) {
    switch (type) {
      case 'meals':
        return Icons.restaurant;
      case 'streak':
        return Icons.local_fire_department;
      case 'calories':
        return Icons.monitor_weight;
      case 'workouts':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'progress':
        return Icons.trending_up;
      case 'weight':
        return Icons.scale;
      case 'muscle':
        return Icons.sports_gymnastics;
      default:
        return Icons.emoji_events;
    }
  }

  // Get color based on achievement type
  Color getColorForType(String type) {
    switch (type) {
      case 'meals':
        return Colors.green;
      case 'streak':
        return Colors.orange;
      case 'calories':
        return Colors.red;
      case 'workouts':
        return Colors.blue;
      case 'cardio':
        return Colors.purple;
      case 'progress':
        return Colors.teal;
      case 'weight':
        return Colors.indigo;
      case 'muscle':
        return Colors.brown;
      default:
        return Colors.amber;
    }
  }

  // Get a human-readable description of the achievement type
  String getTypeDescription(String type, int target) {
    switch (type) {
      case 'meals':
        return 'Log $target meal(s)';
      case 'streak':
        return 'Maintain a streak of $target days';
      case 'calories':
        return '$target calories';
      case 'workouts':
        return 'Complete $target workout(s)';
      case 'cardio':
        return 'Complete $target cardio session(s)';
      case 'progress':
        return 'Log $target progress update(s)';
      case 'weight':
        return 'Change weight by $target kg';
      case 'muscle':
        return 'Gain $target kg of muscle';
      default:
        return 'Complete $target tasks';
    }
  }

  void _showAchievementDetails(
    BuildContext context,
    dynamic achievement,
    bool unlocked,
    dynamic userAchievement,
  ) {
    final Color achievementColor = getColorForType(achievement['type']);
    final IconData achievementIcon = getIconForType(achievement['type']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // Achievement header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  decoration: BoxDecoration(
                    color:
                        unlocked
                            ? achievementColor.withOpacity(0.1)
                            : Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              unlocked
                                  ? achievementColor.withOpacity(0.2)
                                  : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          achievementIcon,
                          color: unlocked ? achievementColor : Colors.grey,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title and status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        unlocked
                                            ? Colors.green.shade100
                                            : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    unlocked ? 'UNLOCKED' : 'LOCKED',
                                    style: TextStyle(
                                      color:
                                          unlocked
                                              ? Colors.green.shade800
                                              : Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  achievement['type'].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          achievement['description'],
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 24),

                        // Requirements
                        Text(
                          'REQUIREMENTS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.flag_outlined,
                                color:
                                    unlocked ? achievementColor : Colors.grey,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Target',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getTargetDescription(
                                        achievement['type'],
                                        achievement['target'],
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Completion details for unlocked achievements
                        if (unlocked) ...[
                          const SizedBox(height: 24),
                          Text(
                            'COMPLETION DETAILS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Completed On',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(
                                          userAchievement['created_at'],
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Progress for locked achievements
                        // if (!unlocked) ...[
                        //   const SizedBox(height: 24),
                        //   Text(
                        //     'YOUR PROGRESS',
                        //     style: TextStyle(
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.w600,
                        //       color: Colors.grey.shade600,
                        //       letterSpacing: 1.2,
                        //     ),
                        //   ),
                        //   const SizedBox(height: 16),
                        //   Container(
                        //     padding: const EdgeInsets.all(16),
                        //     decoration: BoxDecoration(
                        //       color: Colors.grey.shade50,
                        //       borderRadius: BorderRadius.circular(12),
                        //       border: Border.all(color: Colors.grey.shade200),
                        //     ),
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       'Progress toward completion',
                        //       style: TextStyle(
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.w500,
                        //         color: Colors.grey.shade800,
                        //       ),
                        //     ),
                        //     Text(
                        //       '30%', // This would be dynamic in a real app
                        //       style: TextStyle(
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.w600,
                        //         color: Colors.grey.shade800,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 12),
                        // ClipRRect(
                        //   borderRadius: BorderRadius.circular(4),
                        //   child: LinearProgressIndicator(
                        //     value: 0.3, // This would be dynamic in a real app
                        //     minHeight: 8,
                        //     backgroundColor: Colors.grey.shade200,
                        //     valueColor: AlwaysStoppedAnimation<Color>(achievementColor),
                        //   ),
                        // ),
                        // const SizedBox(height: 12),
                        // Text(
                        //   _getProgressText(achievement['type'], achievement['target']),
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     color: Colors.grey.shade600,
                        //   ),
                        // ),
                        //       ],
                        //     ),
                        //   ),
                        // ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String _formatDate(String dateString) {
    // Parse the date string and format it nicely
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString.substring(0, 10); // Fallback to simple substring
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _getTargetDescription(String type, int target) {
    switch (type) {
      case 'meals':
        return 'Log $target meal(s)';
      case 'streak':
        return 'Maintain a streak for $target days';
      case 'calories':
        return target > 1000
            ? 'Reach ${target / 1000}k calories'
            : 'Reach $target calories';
      case 'workouts':
        return 'Complete $target workout(s)';
      case 'cardio':
        return 'Complete $target cardio session(s)';
      case 'progress':
        return 'Log $target progress update(s)';
      case 'weight':
        return 'Lose $target kg';
      case 'muscle':
        return 'Gain $target kg of muscle';
      default:
        return 'Complete $target tasks';
    }
  }

  Widget _buildInfoItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _achievementsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading achievements: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _achievementsData = _loadAchievements();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No achievements found'));
          }

          final allAchievements =
              snapshot.data!['allAchievements'] as List<dynamic>;
          final userAchievementsMap =
              snapshot.data!['userAchievementsMap'] as Map<int, dynamic>;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: allAchievements.length,
            itemBuilder: (context, index) {
              final achievement = allAchievements[index];
              final bool unlocked = userAchievementsMap.containsKey(
                achievement['id'],
              );
              final Color achievementColor = getColorForType(
                achievement['type'],
              );

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      unlocked
                          ? BorderSide(color: achievementColor, width: 2)
                          : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () {
                    _showAchievementDetails(
                      context,
                      achievement,
                      unlocked,
                      unlocked ? userAchievementsMap[achievement['id']] : null,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor:
                                  unlocked
                                      ? achievementColor.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.1),
                              child: Icon(
                                unlocked
                                    ? getIconForType(achievement['type'])
                                    : Icons.lock_outline,
                                size: 36,
                                color:
                                    unlocked ? achievementColor : Colors.grey,
                              ),
                            ),
                            if (unlocked)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          achievement['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: unlocked ? Colors.black : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          unlocked
                              ? achievement['description']
                              : 'Complete to unlock: ${achievement['description']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (unlocked) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: achievementColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'COMPLETED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: achievementColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
