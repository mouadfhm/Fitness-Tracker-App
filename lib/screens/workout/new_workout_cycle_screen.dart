import 'package:fitness_tracker_app/screens/workout/new_workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class NewWorkoutCycleScreen extends StatefulWidget {
  const NewWorkoutCycleScreen({super.key});

  @override
  _NewWorkoutCycleScreenState createState() => _NewWorkoutCycleScreenState();
}

class _NewWorkoutCycleScreenState extends State<NewWorkoutCycleScreen> {
  final ApiService _apiService = ApiService();
  DateTime _startDate = DateTime.now();
  int _weeks = 4;
  final Map<String, int?> _daysPattern = {
    'mon': null,
    'tue': null,
    'wed': null,
    'thu': null,
    'fri': null,
    'sat': null,
    'sun': null,
  };
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

  // For handling API states
  bool _isLoading = false;
  bool _isLoadingWorkouts = true;
  String? _errorMessage;

  // Custom workouts fetched from API
  List<Map<String, dynamic>> _customWorkouts = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomWorkouts();
  }

  Future<void> _fetchCustomWorkouts() async {
    setState(() {
      _isLoadingWorkouts = true;
    });

    try {
      final List<dynamic> workouts =
          await _apiService.fetchWorkout(); // Expecting a List

      setState(() {
        _customWorkouts =
            workouts
                .map(
                  (workout) => {
                    'id': workout['id'],
                    'name': workout['name'],
                    'description': workout['description'],
                  },
                )
                .toList();
        _isLoadingWorkouts = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load custom workouts: ${e.toString()}';
        debugPrint('Failed to load custom workouts: ${e.toString()}');
        _isLoadingWorkouts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Dynamic colors based on theme brightness
    final primaryColor = isDark ? Colors.blueGrey.shade300 : Colors.blueGrey;
    final accentColor = isDark ? Colors.tealAccent.shade700 : Colors.blue;
    
    // Surface colors for containers
    final surfaceColor = isDark 
        ? theme.colorScheme.surface.withOpacity(0.8) 
        : theme.colorScheme.surfaceContainerHighest;
    
    // Border colors that work in both themes
    final borderColor = isDark 
        ? Colors.white24 
        : theme.colorScheme.outlineVariant.withOpacity(0.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Workout Cycle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoadingWorkouts)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accentColor,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCustomWorkouts,
            tooltip: 'Refresh workout list',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState(accentColor, primaryColor)
          : _errorMessage != null
              ? _buildErrorState(theme, accentColor)
              : _buildForm(theme, primaryColor, accentColor, surfaceColor, borderColor),
      bottomNavigationBar: _buildBottomBar(theme, primaryColor, accentColor),
    );
  }

  Widget _buildForm(ThemeData theme, Color primaryColor, Color accentColor, 
      Color surfaceColor, Color borderColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStartDateSection(theme, primaryColor, accentColor, surfaceColor, borderColor),
          const SizedBox(height: 24),
          _buildWeeksSection(theme, primaryColor, accentColor),
          const SizedBox(height: 24),
          _buildDaysPatternSection(theme, primaryColor, accentColor, surfaceColor, borderColor),
        ],
      ),
    );
  }

  Widget _buildStartDateSection(ThemeData theme, Color primaryColor, Color accentColor, 
      Color surfaceColor, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Date',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectStartDate(accentColor),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_startDate),
                  style: theme.textTheme.bodyLarge,
                ),
                Icon(Icons.calendar_today, size: 20, color: accentColor),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your workout cycle will begin on this date',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildWeeksSection(ThemeData theme, Color primaryColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Weeks',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _weeks.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                activeColor: accentColor,
                inactiveColor: accentColor.withOpacity(0.2),
                onChanged: (value) {
                  setState(() {
                    _weeks = value.toInt();
                  });
                },
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$_weeks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Text(
          'Your workout cycle will repeat for $_weeks weeks',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDaysPatternSection(ThemeData theme, Color primaryColor, Color accentColor, 
      Color surfaceColor, Color borderColor) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workout Schedule',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose workouts for each day of the week',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (_customWorkouts.isEmpty && !_isLoadingWorkouts)
              TextButton.icon(
                onPressed: _fetchCustomWorkouts,
                icon: Icon(Icons.refresh, size: 18, color: accentColor),
                label: Text('Refresh', style: TextStyle(color: accentColor)),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Handle cases for custom workouts loading state
        if (_isLoadingWorkouts)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  CircularProgressIndicator(color: accentColor),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your custom workouts...',
                    style: TextStyle(color: primaryColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else if (_customWorkouts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: 64,
                    color: primaryColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No custom workouts found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create custom workouts first before setting up a workout cycle',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewWorkoutScreen(),
                        ),
                      ).then((_) {
                        // Refresh workouts when returning from NewWorkoutScreen
                        _fetchCustomWorkouts();
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Create Workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dayNames.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final dayKey = _dayKeys[index];
              final dayName = _dayNames[index];
              final selectedWorkoutId = _daysPattern[dayKey];

              // Card background that works in both themes
              final cardColor = isDark 
                  ? theme.cardColor.withOpacity(0.7) 
                  : theme.cardColor;

              return Card(
                elevation: isDark ? 2 : 0,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.5),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          dayName.substring(0, 1),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildWorkoutDropdown(
                              theme,
                              dayKey,
                              selectedWorkoutId,
                              accentColor,
                              primaryColor,
                              surfaceColor,
                              borderColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildWorkoutDropdown(
    ThemeData theme,
    String dayKey,
    int? selectedWorkoutId,
    Color accentColor,
    Color primaryColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    // Enhanced contrast for dropdown for better visibility in dark mode
    final dropdownTextColor = theme.brightness == Brightness.dark 
        ? Colors.white 
        : theme.textTheme.bodyMedium?.color;
    
    final addButtonBgColor = theme.brightness == Brightness.dark
        ? accentColor.withOpacity(0.2)
        : accentColor.withOpacity(0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButton<int?>(
            value: selectedWorkoutId,
            hint: Text(
              'Rest day',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: dropdownTextColor?.withOpacity(0.7),
              ),
            ),
            underline: const SizedBox(),
            isExpanded: true,
            dropdownColor: theme.cardColor,
            icon: Icon(Icons.arrow_drop_down, color: accentColor),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text('Rest day', style: TextStyle(color: dropdownTextColor)),
              ),
              ..._customWorkouts.map((workout) {
                return DropdownMenuItem<int?>(
                  value: workout['id'],
                  child: Text(
                    workout['name'],
                    style: TextStyle(color: dropdownTextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ],
            selectedItemBuilder: (BuildContext context) {
              return [
                DropdownMenuItem<String>(
                  value: 'Rest day',
                  child: Text('Rest day', 
                    style: TextStyle(
                      color: dropdownTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ..._customWorkouts.map((workout) {
                  return DropdownMenuItem<String>(
                    value: workout['name'],
                    child: Text(
                      workout['name'],
                      style: TextStyle(
                        color: dropdownTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ];
            },
            onChanged: (newValue) {
              setState(() {
                _daysPattern[dayKey] = newValue;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewWorkoutScreen()),
            ).then((_) {
              // Refresh workouts when returning from NewWorkoutScreen
              _fetchCustomWorkouts();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: addButtonBgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, color: accentColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Add New Workout',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme, Color primaryColor, Color accentColor) {
    final bool hasWorkouts = _customWorkouts.isNotEmpty;
    final isDark = theme.brightness == Brightness.dark;
    
    // Add subtle elevation to bottom bar in dark mode
    final bottomBarColor = isDark
        ? theme.scaffoldBackgroundColor.withOpacity(0.9)
        : theme.scaffoldBackgroundColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bottomBarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: primaryColor),
              ),
              child: Text('Cancel', style: TextStyle(color: primaryColor)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: hasWorkouts && !_isLoadingWorkouts
                  ? _createWorkoutCycle
                  : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: accentColor,
                disabledBackgroundColor: accentColor.withOpacity(0.3),
              ),
              child: const Text('Create Cycle'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(Color accentColor, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: accentColor),
          const SizedBox(height: 16),
          Text(
            'Creating your workout cycle...',
            style: TextStyle(color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, Color accentColor) {
    final errorColor = theme.brightness == Brightness.dark
        ? Colors.red.shade300
        : Colors.red.shade400;
        
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: errorColor),
          const SizedBox(height: 16),
          Text(
            'Error Creating Workout Cycle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'An unknown error occurred',
              style: TextStyle(
                color: theme.brightness == Brightness.dark 
                    ? Colors.grey.shade300
                    : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _selectStartDate(Color accentColor) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark 
                ? ColorScheme.dark(
                    primary: accentColor,
                    onPrimary: Colors.white,
                    surface: theme.cardColor,
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: accentColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.blueGrey,
                  ), dialogTheme: DialogThemeData(backgroundColor: theme.scaffoldBackgroundColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _createWorkoutCycle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Format the date as ISO string (YYYY-MM-DD)
      final formattedDate = DateFormat('yyyy-MM-dd').format(_startDate);

      await _apiService.storeWeeklyWorkouts(
        formattedDate,
        _weeks,
        _daysPattern,
      );

      // If successful, pop and return to the previous screen
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        debugPrint('errrrrr: $e');
        _isLoading = false;
      });
    }
  }
}