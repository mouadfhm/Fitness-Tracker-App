// ignore_for_file: library_private_types_in_public_api

import 'package:fitness_tracker_app/screens/workout/new_workout_cycle_screen.dart';
import 'package:fitness_tracker_app/screens/workout/new_workout_screen.dart';
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
  final List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final List<String> _dayKeys = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  // Initialize _selectedDayIndex with current day of week (0-6, Monday-Sunday)
  int _selectedDayIndex = DateTime.now().weekday - 1;

  // Custom app colors - will be initialized based on theme
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _accentColor;
  late Color _textColor;
  late Color _surfaceColor;
  late Color _cardBorderColor;
  late Color _iconColor;
  final int _currentIndex = 1;

  // Add these properties for workouts
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _workouts = [];
  List<Map<String, dynamic>> _filteredWorkouts = [];

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
    _fetchWorkouts(); // Fetch available workouts when the screen loads
  }

  void _fetchWeeklyPlan() {
    if (mounted) {
      setState(() {
        _weeklyPlanFuture = _apiService.fetchWeeklyWorkouts();
      });
    }
  }

  //delete schedule workout
  void _deleteScheduleWorkout(int scheduleWorkoutId) async {
    await _apiService.deleteScheduleWorkout(scheduleWorkoutId);
    if (mounted) {
      _fetchWeeklyPlan();
    }
  }

  // Method to fetch workouts
  Future<void> _fetchWorkouts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<dynamic> workouts = await _apiService.fetchWorkout();
      if (mounted) {
        setState(() {
          _workouts =
              workouts
                  .map((workout) => workout as Map<String, dynamic>)
                  .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load workouts: ${e.toString()}';
          debugPrint('Failed to load workouts: ${e.toString()}');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Initialize colors based on theme brightness
    _primaryColor = isDarkMode ? Colors.tealAccent.shade700 : Colors.blueGrey;
    _secondaryColor = isDarkMode ? Colors.tealAccent : Colors.blueAccent;
    _accentColor = isDarkMode ? Colors.tealAccent.shade400 : Colors.blue;
    _textColor = isDarkMode ? Colors.white : Colors.black87;
    _surfaceColor = isDarkMode ? const Color(0xFF303030) : Colors.white;
    _cardBorderColor =
        isDarkMode
            ? Colors.tealAccent.withOpacity(0.3)
            : theme.colorScheme.outlineVariant.withOpacity(0.5);
    _iconColor = isDarkMode ? Colors.tealAccent.shade200 : Colors.blueGrey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Workouts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : null,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : null,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDarkMode ? _secondaryColor : null,
            ),
            onPressed: _fetchWeeklyPlan,
            tooltip: 'Refresh workout plan',
          ),
        ],
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _weeklyPlanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: _secondaryColor),
            );
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data == null) {
            return _buildEmptyState('No workout plan available');
          }

          final weeklyPlan = snapshot.data!;
          final weeks = weeklyPlan['weeks'] as Map<String, dynamic>?;

          if (weeks == null ||
              !weeks.containsKey(_currentWeekNumber.toString())) {
            return _buildEmptyState(
              'No workout plan for week $_currentWeekNumber',
            );
          }

          final currentWeekData =
              weeks[_currentWeekNumber.toString()] as Map<String, dynamic>;

          return Column(
            children: [
              _buildWeekNavigation(theme),
              _buildDaysSelector(theme, currentWeekData),
              Divider(
                height: 1,
                color: isDarkMode ? Colors.white24 : Colors.black12,
              ),
              _buildWorkoutsList(theme, currentWeekData),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildWeekNavigation(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black26 : _primaryColor.withOpacity(0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            style: IconButton.styleFrom(
              foregroundColor: _secondaryColor,
              backgroundColor:
                  isDarkMode ? Colors.black38 : _primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _secondaryColor.withOpacity(0.5),
                  width: 1.5,
                ),
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
                  color: isDarkMode ? Colors.white : _primaryColor,
                ),
              ),
              Text(
                '2025',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      isDarkMode
                          ? Colors.white70
                          : _primaryColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            style: IconButton.styleFrom(
              foregroundColor: _secondaryColor,
              backgroundColor:
                  isDarkMode ? Colors.black38 : _primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _secondaryColor.withOpacity(0.5),
                  width: 1.5,
                ),
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
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [Colors.black45, Colors.transparent]
                  : [_primaryColor.withOpacity(0.05), Colors.transparent],
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
            final isToday =
                index == (DateTime.now().weekday - 1) &&
                _currentWeekNumber == DateTime.now().weekOfYear;

            // Calculate colors based on states and theme
            final backgroundColor =
                isSelected
                    ? _secondaryColor.withOpacity(0.8)
                    : (isToday
                        ? (isDarkMode
                            ? Colors.teal.withOpacity(0.3)
                            : _primaryColor.withOpacity(0.15))
                        : (isDarkMode
                            ? Colors.black38
                            : theme.colorScheme.surfaceContainerHighest));

            final textColor =
                isSelected
                    ? (isDarkMode ? Colors.black : Colors.white)
                    : (isToday
                        ? _secondaryColor
                        : (isDarkMode
                            ? Colors.white70
                            : theme.colorScheme.onSurfaceVariant));

            final dotColor =
                hasWorkout
                    ? (isSelected
                        ? (isDarkMode ? Colors.black : Colors.white)
                        : _accentColor)
                    : Colors.transparent;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDayIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isToday && !isSelected
                          ? Border.all(color: _secondaryColor, width: 2)
                          : null,
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color:
                                  isDarkMode
                                      ? _secondaryColor.withOpacity(0.3)
                                      : _primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
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
                        color: textColor,
                        fontWeight:
                            isToday || isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor,
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
    final isDarkMode = theme.brightness == Brightness.dark;

    if (workouts.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 64,
                color:
                    isDarkMode
                        ? _secondaryColor.withOpacity(0.3)
                        : _primaryColor.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No workouts for $selectedDayName',
                style: theme.textTheme.titleMedium?.copyWith(
                  color:
                      isDarkMode
                          ? Colors.white70
                          : _primaryColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // Show workout selection dialog when Add Workout is pressed
                  _showWorkoutSelectionDialog(context, selectedDayKey);
                },
                icon: Icon(
                  Icons.add,
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
                label: const Text('Add Workout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
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
                colors:
                    isDarkMode
                        ? [Colors.black38, Colors.transparent]
                        : [_primaryColor.withOpacity(0.05), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Workouts for $selectedDayName',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : _primaryColor,
                  ),
                ),
                // Add a button to add more workouts even when there are existing workouts
                IconButton(
                  icon: Icon(Icons.add_circle, color: _accentColor),
                  onPressed: () {
                    _showWorkoutSelectionDialog(context, selectedDayKey);
                  },
                  tooltip: 'Add more workouts',
                ),
              ],
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

  // Workout selection dialog with improved dark mode support
  void _showWorkoutSelectionDialog(BuildContext context, String dayKey) async {
    // Fetch workouts if not already loaded
    if (_workouts.isEmpty && !_isLoading) {
      await _fetchWorkouts();
    }

    // Initialize filtered workouts with all workouts
    _filteredWorkouts = List.from(_workouts);

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? const Color(0xFF202020) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Add Workout',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : _primaryColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDarkMode ? Colors.white70 : null,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Add a prominent button to create a new workout
                  ElevatedButton.icon(
                    onPressed: () {
                      // Close the current dialog
                      Navigator.pop(context);
                      // Navigate to the NewWorkoutScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewWorkoutScreen(),
                        ),
                      ).then((_) {
                        // Refresh workouts list when returning from the create screen
                        _fetchWorkouts();
                      });
                    },
                    icon: Icon(
                      Icons.add,
                      color: isDarkMode ? Colors.black : Colors.white,
                    ),
                    label: const Text('Create New Workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: isDarkMode ? Colors.black : Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search workouts...',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey : Colors.grey.shade600,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.grey : null,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        // Filter workouts based on search text
                        if (value.isEmpty) {
                          // If search is empty, show all workouts
                          _filteredWorkouts = List.from(_workouts);
                        } else {
                          // Filter workouts by name or description containing the search text
                          _filteredWorkouts =
                              _workouts.where((workout) {
                                final name =
                                    (workout['name'] as String).toLowerCase();
                                final description =
                                    workout['description'] != null
                                        ? (workout['description'] as String)
                                            .toLowerCase()
                                        : '';
                                final searchLower = value.toLowerCase();

                                return name.contains(searchLower) ||
                                    description.contains(searchLower);
                              }).toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Available Workouts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child:
                        _isLoading
                            ? Center(
                              child: CircularProgressIndicator(
                                color: _accentColor,
                              ),
                            )
                            : _errorMessage != null
                            ? Center(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.redAccent
                                          : Colors.red,
                                ),
                              ),
                            )
                            : _filteredWorkouts.isEmpty && _workouts.isNotEmpty
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color:
                                        isDarkMode
                                            ? Colors.grey.shade600
                                            : _primaryColor.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No matching workouts found',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      color:
                                          isDarkMode
                                              ? Colors.grey
                                              : _primaryColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : _workouts.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.fitness_center_outlined,
                                    size: 64,
                                    color:
                                        isDarkMode
                                            ? Colors.grey.shade600
                                            : _primaryColor.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No workouts available',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      color:
                                          isDarkMode
                                              ? Colors.grey
                                              : _primaryColor.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Create your first workout',
                                    style: TextStyle(
                                      color:
                                          isDarkMode
                                              ? Colors.grey.shade400
                                              : null,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.separated(
                              itemCount: _filteredWorkouts.length,
                              separatorBuilder:
                                  (context, index) => Divider(
                                    color:
                                        isDarkMode
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade200,
                                  ),
                              itemBuilder: (context, index) {
                                final workout = _filteredWorkouts[index];
                                return ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _getWorkoutColor(
                                        workout['name'] as String,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getWorkoutIcon(
                                        workout['name'] as String,
                                      ),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    workout['name'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : _primaryColor,
                                    ),
                                  ),
                                  subtitle:
                                      workout['description'] != null
                                          ? Text(
                                            workout['description'] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  isDarkMode
                                                      ? Colors.grey.shade400
                                                      : null,
                                            ),
                                          )
                                          : null,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: _accentColor,
                                    onPressed: () {
                                      _addWorkoutToDay(workout, dayKey);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  onTap: () {
                                    _addWorkoutToDay(workout, dayKey);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Method to add a workout to a specific day
  Future<void> _addWorkoutToDay(
    Map<String, dynamic> workout,
    String dayKey,
  ) async {
    try {
      // Calculate the date string in yyyy-mm-dd format for the selected day
      final now = DateTime.now();
      final currentWeek = DateTime.now().weekOfYear;

      // Calculate the difference in weeks
      final weekDifference = _currentWeekNumber - currentWeek;

      // Get the first day of the current week (Monday)
      final firstDayOfCurrentWeek = now.subtract(
        Duration(days: now.weekday - 1),
      );

      // Add the week difference
      final firstDayOfSelectedWeek = firstDayOfCurrentWeek.add(
        Duration(days: 7 * weekDifference),
      );

      // Add the day offset (0 for Monday, 1 for Tuesday, etc.)
      final dayOffset = _dayKeys.indexOf(dayKey);
      final selectedDate = firstDayOfSelectedWeek.add(
        Duration(days: dayOffset),
      );

      // Format the date as yyyy-mm-dd
      final dateString =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      // Add the workout to the schedule for the selected date
      await _apiService.storeScheduleWorkout(workout['id'], dateString);

      // Refresh the weekly plan to show the newly added workout
      // Refresh the weekly plan to show the newly added workout
      if (mounted) {
        _fetchWeeklyPlan();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add workout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // If you have any StreamSubscriptions, Timers, or other resources
    // that need to be cleaned up, do it here
    super.dispose();
  }

  Widget _buildWorkoutCard(ThemeData theme, dynamic workout) {
    final workoutData = workout['workout'];
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: isDarkMode ? const Color(0xFF2A2A2A) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isDarkMode
                  ? _secondaryColor.withOpacity(0.3)
                  : theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: isDarkMode ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      WorkoutDetailScreen(workoutId: workoutData['id']),
            ),
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
                      boxShadow:
                          isDarkMode
                              ? [
                                BoxShadow(
                                  color: _getWorkoutColor(
                                    workoutData['name'] as String,
                                  ).withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
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
                            color: isDarkMode ? Colors.white : _primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (workoutData['description'] != null &&
                            workoutData['description'].isNotEmpty)
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
                          builder:
                              (context) => WorkoutDetailScreen(
                                workoutId: workoutData['id'],
                              ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: _primaryColor,
                    ),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                      foregroundColor: _primaryColor,
                      side: BorderSide(color: _primaryColor),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteScheduleWorkout(workout['id']),
                    tooltip: 'Remove exercise',
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
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text('Next Week'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewWorkoutCycleScreen(),
                ),
              );
            },
            icon: Icon(Icons.add, color: _surfaceColor),
            label: const Text('Create Workout Plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _secondaryColor,
              foregroundColor: _surfaceColor,
            ),
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
