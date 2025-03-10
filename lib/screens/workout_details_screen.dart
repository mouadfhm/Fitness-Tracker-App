// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fitness_tracker_app/providers/profile_provider.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final dynamic workout;

  const WorkoutDetailsScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _durationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isAddingWorkout = false;
  String? _addWorkoutMessage;
  final ApiService apiService = ApiService();

  // Helper methods for dynamic styling - bringing over from WorkoutScreen
  Color _getCategoryColor(String category) {
    final String cat = category.toLowerCase();

    // Strength and weight training
    if (cat.contains('strength') ||
        cat.contains('weight') ||
        cat.contains('gym')) {
      return Colors.blue.shade700;
    }
    // Cardio activities
    else if (cat.contains('cardio') ||
        cat.contains('run') ||
        cat.contains('jog')) {
      return Colors.red.shade600;
    }
    // Flexibility activities
    else if (cat.contains('flex') ||
        cat.contains('stretch') ||
        cat.contains('yoga')) {
      return Colors.purple.shade600;
    }
    // Ball sports
    else if (cat.contains('basketball') ||
        cat.contains('football') ||
        cat.contains('soccer') ||
        cat.contains('tennis') ||
        cat.contains('volleyball') ||
        cat.contains('baseball')) {
      return Colors.orange.shade600;
    }
    // Cycling activities
    else if (cat.contains('cycling') ||
        cat.contains('bike') ||
        cat.contains('biking')) {
      return Colors.green.shade600;
    }
    // Water sports
    else if (cat.contains('swim') ||
        cat.contains('water') ||
        cat.contains('diving')) {
      return Colors.lightBlue.shade600;
    }
    // Combat sports
    else if (cat.contains('boxing') ||
        cat.contains('martial') ||
        cat.contains('fight') ||
        cat.contains('karate') ||
        cat.contains('judo') ||
        cat.contains('mma')) {
      return Colors.red.shade800;
    }
    // Precision sports
    else if (cat.contains('golf') ||
        cat.contains('archery') ||
        cat.contains('shooting')) {
      return Colors.teal.shade600;
    }
    // Winter sports
    else if (cat.contains('ski') ||
        cat.contains('snow') ||
        cat.contains('ice') ||
        cat.contains('hockey') ||
        cat.contains('skating')) {
      return Colors.blue.shade300;
    }
    // Racket sports (not already covered by ball sports)
    else if (cat.contains('badminton') ||
        cat.contains('squash') ||
        cat.contains('racket')) {
      return Colors.yellow.shade800;
    }
    // Outdoor activities
    else if (cat.contains('hike') ||
        cat.contains('climb') ||
        cat.contains('trail') ||
        cat.contains('trek') ||
        cat.contains('mountain')) {
      return Colors.brown.shade600;
    }
    // Default case - generate a color based on hash
    else {
      final int hash = cat.hashCode.abs();
      return Color.fromARGB(
        255,
        (hash % 150) + 50,
        ((hash ~/ 10) % 150) + 50,
        ((hash ~/ 100) % 150) + 50,
      );
    }
  }

  IconData _getCategoryIcon(String category) {
    final String cat = category.toLowerCase();

    // Strength and weight training
    if (cat.contains('strength') ||
        cat.contains('weight') ||
        cat.contains('gym')) {
      return Icons.fitness_center;
    }
    // Running activities
    else if (cat.contains('run') ||
        cat.contains('jog') ||
        cat.contains('marathon')) {
      return Icons.directions_run;
    }
    // General cardio
    else if (cat.contains('cardio') ||
        cat.contains('hiit') ||
        cat.contains('aerobic')) {
      return Icons.favorite;
    }
    // Flexibility activities
    else if (cat.contains('flex') ||
        cat.contains('yoga') ||
        cat.contains('stretch')) {
      return Icons.accessibility_new;
    }
    // Basketball
    else if (cat.contains('basketball')) {
      return Icons.sports_basketball;
    }
    // Football/Soccer
    else if (cat.contains('football') || cat.contains('soccer')) {
      return Icons.sports_soccer;
    }
    // Tennis
    else if (cat.contains('tennis')) {
      return Icons.sports_tennis;
    }
    // Other sports categories from WorkoutScreen
    else if (cat.contains('baseball')) {
      return Icons.sports_baseball;
    } else if (cat.contains('volleyball')) {
      return Icons.sports_volleyball;
    } else if (cat.contains('golf')) {
      return Icons.sports_golf;
    } else if (cat.contains('cycling') ||
        cat.contains('bike') ||
        cat.contains('biking')) {
      return Icons.pedal_bike;
    } else if (cat.contains('swim') || cat.contains('pool')) {
      return Icons.pool;
    } else if (cat.contains('boxing') ||
        cat.contains('martial') ||
        cat.contains('karate') ||
        cat.contains('judo') ||
        cat.contains('mma') ||
        cat.contains('fight')) {
      return Icons.sports_martial_arts;
    }
    // Default
    else {
      return Icons.fitness_center;
    }
  }

  Widget _buildDifficultyIndicator(String difficulty) {
    Color color;
    int level;

    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'beginner':
        color = Colors.green;
        level = 1;
        break;
      case 'medium':
      case 'intermediate':
        color = Colors.orange;
        level = 2;
        break;
      case 'hard':
      case 'advanced':
      case 'expert':
        color = Colors.red;
        level = 3;
        break;
      default:
        color = Colors.grey;
        level = 1;
    }

    return Row(
      children: List.generate(3, (index) {
        return Container(
          width: 5,
          height: index < 2 ? 8 : 12,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: index < level ? color : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addWorkout() async {
    final workoutName = widget.workout['description'] ?? 'Unknown Workout';
    final durationText = _durationController.text.trim();

    if (durationText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a duration")));
      return;
    }

    final int? duration = int.tryParse(durationText);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid duration")),
      );
      return;
    }

    final workoutDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    setState(() {
      _isAddingWorkout = true;
      _addWorkoutMessage = null;
    });

    try {
      await _apiService.storeWorkout(workoutName, duration, workoutDate);
      setState(() {
        _addWorkoutMessage = "Workout added successfully!";
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (error) {
      setState(() {
        _addWorkoutMessage = "Error: ${error.toString()}";
      });
    } finally {
      setState(() {
        _isAddingWorkout = false;
      });
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.workout['name'] ?? 'No Name';
    final description = widget.workout['description'] ?? 'No Description';
    final category = widget.workout['name'] ?? 'Uncategorized';
    final difficulty =
        widget.workout['caloriesPerKg'] > 2
            ? 'Hard'
            : widget.workout['caloriesPerKg'] > 1
            ? 'Medium'
            : 'Easy';

    final Color categoryColor = _getCategoryColor(category);
    final IconData categoryIcon = _getCategoryIcon(category);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final weight = profileProvider.profileData?['weight'] ?? 0;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with workout icon and colors
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: categoryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                color: categoryColor,
                child: Center(
                  child: Icon(
                    categoryIcon,
                    size: 80,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        difficulty,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildDifficultyIndicator(difficulty),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Workout Detail Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About This Workout Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: categoryColor,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "About This Workout",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: categoryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Category badge
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      categoryIcon,
                                      size: 16,
                                      color: categoryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: categoryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Description
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade800,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Stats Row
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  Icons.local_fire_department,
                                  "Intensity",
                                  difficulty,
                                  difficulty == 'Easy'
                                      ? Colors.green
                                      : difficulty == 'Medium'
                                      ? Colors.orange
                                      : Colors.red,
                                ),
                                _buildStatItem(
                                  Icons.flash_on,
                                  "Calories",
                                  "${(widget.workout['caloriesPerKg'] * weight).toStringAsFixed(0) }/hr",
                                  Colors.blue.shade700,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Schedule Workout Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: categoryColor,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Schedule Workout",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: categoryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Date Picker
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.event, color: categoryColor),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat(
                                          'EEE, MMM d, yyyy',
                                        ).format(_selectedDate),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Duration Input
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer, color: categoryColor),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _durationController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Duration in minutes",
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Add to Plan Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isAddingWorkout ? null : _addWorkout,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: categoryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  _isAddingWorkout
                                      ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        "Add to My Plan",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),

                          // Success/Error Message
                          if (_addWorkoutMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      _addWorkoutMessage!.startsWith("Error")
                                          ? Colors.red.shade50
                                          : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        _addWorkoutMessage!.startsWith("Error")
                                            ? Colors.red.shade200
                                            : Colors.green.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _addWorkoutMessage!.startsWith("Error")
                                          ? Icons.error
                                          : Icons.check_circle,
                                      color:
                                          _addWorkoutMessage!.startsWith(
                                                "Error",
                                              )
                                              ? Colors.red.shade600
                                              : Colors.green.shade600,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _addWorkoutMessage!,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color:
                                              _addWorkoutMessage!.startsWith(
                                                    "Error",
                                                  )
                                                  ? Colors.red.shade800
                                                  : Colors.green.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
