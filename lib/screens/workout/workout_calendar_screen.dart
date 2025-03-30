// ignore_for_file: library_private_types_in_public_api

import 'package:fitness_tracker_app/screens/workout/new_workout_cycle_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import './workout_detail_screen.dart';
import '../profile_screen.dart';
import '../home_screen.dart';
import '../foods_screen.dart';

import '../widgets/bottom_nav_bar.dart';

class WorkoutCalendarScreen extends StatefulWidget {
  const WorkoutCalendarScreen({super.key});

  @override
  _WorkoutCalendarScreenState createState() => _WorkoutCalendarScreenState();
}

class _WorkoutCalendarScreenState extends State<WorkoutCalendarScreen> {
  late Future<Map<String, dynamic>> _weeklyPlanFuture;
  final ApiService _apiService = ApiService();
  int _currentWeekNumber = DateTime.now().weekOfYear;
  final List<String> _dayAbbreviations = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<String> _dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> _dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  
  // Initialize _selectedDayIndex with current day of week (0-6, Monday-Sunday)
  int _selectedDayIndex = DateTime.now().weekday - 1;

  // Custom app colors
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _accentColor;
  final int _currentIndex = 1;

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

  @override
  void initState() {
    super.initState();
    _fetchWeeklyPlan();
  }

  void _fetchWeeklyPlan() {
    setState(() {
      _weeklyPlanFuture = _apiService.fetchWeeklyWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Initialize custom colors
    _primaryColor = Colors.blueGrey;
    _secondaryColor = Colors.greenAccent;
    _accentColor = Colors.blue;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Workouts'),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: _primaryColor.withOpacity(0.1),
        foregroundColor: _primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeeklyPlan,
            tooltip: 'Refresh workout plan',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _weeklyPlanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _primaryColor));
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data == null) {
            return _buildEmptyState('No workout plan available');
          }

          final weeklyPlan = snapshot.data!;
          final weeks = weeklyPlan['weeks'] as Map<String, dynamic>?;
          
          if (weeks == null || !weeks.containsKey(_currentWeekNumber.toString())) {
            return _buildEmptyState('No workout plan for week $_currentWeekNumber');
          }

          final currentWeekData = weeks[_currentWeekNumber.toString()] as Map<String, dynamic>;
          
          return Column(
            children: [
              _buildWeekNavigation(theme),
              _buildDaysSelector(theme, currentWeekData),
              const Divider(height: 1),
              _buildWorkoutsList(theme, currentWeekData),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewWorkoutCycleScreen(
              )
            )
);
        },
        tooltip: 'Create Workout Plan',
        elevation: 2,
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: const Icon(Icons.add),
      ),
            bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),

    );
  }

  Widget _buildWeekNavigation(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            style: IconButton.styleFrom(
              foregroundColor: _primaryColor,
              backgroundColor: _primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _primaryColor.withOpacity(0.3)),
              ),
              padding: const EdgeInsets.all(12),
            ),
            onPressed: () {
              setState(() {
                _currentWeekNumber--;
                // Keep the same day selected when changing weeks
              });
            },
          ),
          Column(
            children: [
              Text(
                'Week $_currentWeekNumber',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              Text(
                '2025',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _primaryColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            style: IconButton.styleFrom(
              foregroundColor: _primaryColor,
              backgroundColor: _primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _primaryColor.withOpacity(0.3)),
              ),
              padding: const EdgeInsets.all(12),
            ),
            onPressed: () {
              setState(() {
                _currentWeekNumber++;
                // Keep the same day selected when changing weeks
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSelector(ThemeData theme, Map<String, dynamic> weekData) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryColor.withOpacity(0.05),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(7, (index) {
            final dayKey = _dayKeys[index];
            final workouts = weekData[dayKey] as List<dynamic>? ?? [];
            final hasWorkout = workouts.isNotEmpty;
            final isSelected = index == _selectedDayIndex;
            final isToday = index == (DateTime.now().weekday - 1) && 
                            _currentWeekNumber == DateTime.now().weekOfYear;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDayIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? _primaryColor 
                      : (isToday ? _primaryColor.withOpacity(0.15) : theme.colorScheme.surfaceVariant),
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSelected 
                      ? Border.all(color: _primaryColor, width: 2) 
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                width: 48,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _dayAbbreviations[index],
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isSelected 
                            ? Colors.white 
                            : (isToday ? _primaryColor : theme.colorScheme.onSurfaceVariant),
                        fontWeight: isToday ? FontWeight.bold : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasWorkout 
                            ? (isSelected ? Colors.white : _secondaryColor)
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWorkoutsList(ThemeData theme, Map<String, dynamic> weekData) {
    final selectedDayKey = _dayKeys[_selectedDayIndex];
    final selectedDayName = _dayNames[_selectedDayIndex];
    final workouts = weekData[selectedDayKey] as List<dynamic>? ?? [];
    
    if (workouts.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 64,
                color: _primaryColor.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No workouts for $selectedDayName',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _primaryColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to create workout screen
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Workout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primaryColor.withOpacity(0.05),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Text(
              'Workouts for $selectedDayName',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: workouts.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return _buildWorkoutCard(theme, workout);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(ThemeData theme, dynamic workout) {
    final workoutData = workout['workout'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(
                workoutId: workoutData['id'],
              )
            )
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getWorkoutColor(workoutData['name'] as String),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getWorkoutIcon(workoutData['name'] as String),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workoutData['name'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (workoutData['description'] != null && workoutData['description'].isNotEmpty)
                          Text(
                            workoutData['description'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => WorkoutDetailScreen(
                            workoutId: workoutData['id'],
                          )
                        )
                      );
                    },
                    icon: Icon(Icons.info_outline, size: 16, color: _primaryColor),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      visualDensity: VisualDensity.compact,
                      foregroundColor: _primaryColor,
                      side: BorderSide(color: _primaryColor),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      // Start workout
                    },
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Start'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getWorkoutIcon(String workoutName) {
    final name = workoutName.toLowerCase();
    if (name.contains('cardio') || name.contains('run')) {
      return Icons.directions_run;
    } else if (name.contains('yoga') || name.contains('stretch')) {
      return Icons.self_improvement;
    } else if (name.contains('chest') || name.contains('push')) {
      return Icons.fitness_center;
    } else if (name.contains('leg')) {
      return Icons.accessibility_new;
    } else {
      return Icons.fitness_center;
    }
  }

  // New method to get different colors for different workout types
  Color _getWorkoutColor(String workoutName) {
    final name = workoutName.toLowerCase();
    if (name.contains('cardio') || name.contains('run')) {
      return Colors.orange;
    } else if (name.contains('back') || name.contains('pull')) {
      return Colors.green;
    } else if (name.contains('chest') || name.contains('push')) {
      return Colors.blue;
    } else if (name.contains('leg')) {
      return Colors.purple;
    } else {
      return _secondaryColor;
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading workouts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchWeeklyPlan,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: _primaryColor.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentWeekNumber--;
                  });
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous Week'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentWeekNumber++;
                  });
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next Week'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Extension to get week of year
extension DateTimeExtension on DateTime {
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final dayOfYear = difference(firstDayOfYear).inDays;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }
}