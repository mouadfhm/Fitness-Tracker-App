import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EditWorkoutScreen extends StatefulWidget {
  final int workoutId;

  const EditWorkoutScreen({super.key, required this.workoutId});

  @override
  _EditWorkoutScreenState createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  // Selected exercises
  List<Map<String, dynamic>> _selectedExercises = [];

  // List of available exercises
  List<Map<String, dynamic>> _gymExercises = [];

  // UI states
  bool _isLoading = false;
  bool _isLoadingExercises = true;
  String? _errorMessage;
  late Future<Map<String, dynamic>> _workoutFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _fetchWorkoutDetails();
    _fetchGymExercises();
  }

  void _fetchWorkoutDetails() async {
    _workoutFuture = _apiService.fetchCustomWorkout(widget.workoutId);
    final workoutData = await _workoutFuture;
    setState(() {
      _nameController.text = workoutData['name'];
      _descriptionController.text = workoutData['description'];
      
      // Transform the gym_exercises data to include the pivot information
      _selectedExercises = List<Map<String, dynamic>>.from(
        (workoutData['gym_exercises'] ?? []).map((exercise) => {
          'id': exercise['id'],
          'name': exercise['name'],
          'description': exercise['description'],
          'body_part': exercise['body_part'],
          'equipment': exercise['equipment'],
          'level': exercise['level'],
          'type': exercise['type'],
          // Add the pivot data
          'sets': exercise['pivot']['sets'],
          'reps': exercise['pivot']['reps'],
          'duration': exercise['pivot']['duration'],
          'rest': exercise['pivot']['rest'],
        }).toList(),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchGymExercises() async {
    setState(() {
      _isLoadingExercises = true;
      _errorMessage = null;
    });

    try {
      final List<dynamic> exercises = await _apiService.getGymExercises();
      setState(() {
        _gymExercises =
            exercises.map((exercise) {
              return {
                'id': exercise['id'],
                'name': exercise['name'],
                'description': exercise['description'],
                'body_part': exercise['body_part'],
                'equipment': exercise['equipment'],
                'level': exercise['level'],
                'type': exercise['type'],
              };
            }).toList();

        _isLoadingExercises = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load exercises: ${e.toString()}';
        debugPrint('Failed to load exercises: ${e.toString()}');
        _isLoadingExercises = false;
      });
    }
  }

  Future<void> _updateWorkout() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise to your workout'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();

      // Format exercises in the required format
      final gymExercises =
          _selectedExercises
              .map(
                (exercise) => {
                  'gym_exercise_id': exercise['id'],
                  'sets': exercise['sets'],
                  'reps': exercise['reps'],
                  'duration': exercise['duration'],
                  'rest': exercise['rest'],
                },
              )
              .toList();

      await _apiService.updateCustomWorkout(
        widget.workoutId,
        name,
        description,
        gymExercises,
      );

      // If successful, pop and return to the previous screen
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addExercise(Map<String, dynamic> exercise) {
    // Add default values
    final exerciseWithDefaults = {
      ...exercise,
      'sets': 3,
      'reps': 12,
      'duration': null,
      'rest': 60,
    };

    setState(() {
      _selectedExercises.add(exerciseWithDefaults);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  void _updateExerciseDetails(int index, String field, dynamic value) {
    setState(() {
      _selectedExercises[index][field] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Adaptive colors based on theme
    final primaryColor = isDarkMode ? Colors.tealAccent.shade400 : Colors.blueGrey;
    final accentColor = isDarkMode ? Colors.tealAccent.shade700 : Colors.blue;
    final cardBgColor = isDarkMode ? Colors.grey.shade900 : theme.cardColor;
    final cardBorderColor = isDarkMode 
        ? Colors.grey.shade700 
        : theme.colorScheme.outlineVariant.withOpacity(0.5);
    final hintTextColor = isDarkMode
        ? Colors.grey.shade400
        : theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Workout'),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: isDarkMode 
            ? Colors.grey.shade900
            : primaryColor.withOpacity(0.1),
        foregroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoadingExercises)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchGymExercises,
            tooltip: 'Refresh exercise list',
          ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingState(accentColor, primaryColor)
              : _errorMessage != null
              ? _buildErrorState(theme)
              : _buildForm(theme, primaryColor, accentColor, cardBgColor, cardBorderColor, hintTextColor),
      bottomNavigationBar: _buildBottomBar(theme, primaryColor, accentColor),
    );
  }

  Widget _buildForm(
    ThemeData theme, 
    Color primaryColor, 
    Color accentColor, 
    Color cardBgColor, 
    Color cardBorderColor,
    Color hintTextColor,
  ) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(theme, primaryColor, cardBgColor, cardBorderColor, hintTextColor),
            const SizedBox(height: 24),
            _buildExercisesSection(theme, primaryColor, accentColor, cardBgColor, cardBorderColor, hintTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(
    ThemeData theme, 
    Color primaryColor, 
    Color cardBgColor, 
    Color cardBorderColor,
    Color hintTextColor,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final textFieldBgColor = isDarkMode 
        ? Colors.grey.shade800 
        : theme.colorScheme.surfaceVariant;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Workout Name',
            labelStyle: TextStyle(color: primaryColor),
            hintText: 'e.g., Upper Body Strength',
            hintStyle: TextStyle(color: hintTextColor),
            filled: true,
            fillColor: textFieldBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cardBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cardBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            prefixIcon: Icon(Icons.fitness_center, color: primaryColor),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a workout name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Description',
            labelStyle: TextStyle(color: primaryColor),
            hintText: 'Focus of this workout, target muscle groups, etc.',
            hintStyle: TextStyle(color: hintTextColor),
            filled: true,
            fillColor: textFieldBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cardBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cardBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            prefixIcon: Icon(Icons.description, color: primaryColor),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildExercisesSection(
    ThemeData theme, 
    Color primaryColor, 
    Color accentColor, 
    Color cardBgColor, 
    Color cardBorderColor,
    Color hintTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Exercises',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showExerciseSelector(context, primaryColor, accentColor),
              icon: Icon(Icons.add, color: accentColor),
              label: Text(
                'Add Exercise',
                style: TextStyle(color: accentColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add exercises and configure sets, reps, and rest periods',
          style: theme.textTheme.bodySmall?.copyWith(
            color: hintTextColor,
          ),
        ),
        const SizedBox(height: 16),

        // Selected exercises list
        _selectedExercises.isEmpty
            ? _buildEmptyExercisesState(theme, primaryColor, hintTextColor)
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedExercises.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final exercise = _selectedExercises[index];
                return _buildExerciseCard(
                  theme, exercise, index, cardBgColor, cardBorderColor, hintTextColor
                );
              },
            ),
      ],
    );
  }

  Widget _buildEmptyExercisesState(ThemeData theme, Color primaryColor, Color hintTextColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No exercises added yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add exercises to update your custom workout',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hintTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    ThemeData theme,
    Map<String, dynamic> exercise,
    int index,
    Color cardBgColor,
    Color cardBorderColor,
    Color hintTextColor,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      color: cardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exercise['body_part']} • ${exercise['level']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: hintTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeExercise(index),
                  tooltip: 'Remove exercise',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Sets
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sets',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Theme(
                        data: theme.copyWith(
                          inputDecorationTheme: InputDecorationTheme(
                            fillColor: isDarkMode ? Colors.grey.shade800 : null,
                            filled: true,
                          ),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: exercise['sets'],
                          dropdownColor: isDarkMode ? Colors.grey.shade800 : null,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: cardBorderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: cardBorderColor),
                            ),
                          ),
                          items:
                              List.generate(10, (i) => i + 1)
                                  .map(
                                    (i) => DropdownMenuItem(
                                      value: i,
                                      child: Text('$i'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _updateExerciseDetails(index, 'sets', value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Reps
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reps',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Theme(
                        data: theme.copyWith(
                          inputDecorationTheme: InputDecorationTheme(
                            fillColor: isDarkMode ? Colors.grey.shade800 : null,
                            filled: true,
                          ),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: exercise['reps'],
                          dropdownColor: isDarkMode ? Colors.grey.shade800 : null,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: cardBorderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: cardBorderColor),
                            ),
                          ),
                          items:
                              [8, 10, 12, 15, 20]
                                  .map(
                                    (i) => DropdownMenuItem(
                                      value: i,
                                      child: Text('$i'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _updateExerciseDetails(index, 'reps', value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Rest
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rest (sec)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Theme(
                        data: theme.copyWith(
                          inputDecorationTheme: InputDecorationTheme(
                            fillColor: isDarkMode ? Colors.grey.shade800 : null,
                            filled: true,
                          ),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: exercise['rest'],
                          dropdownColor: isDarkMode ? Colors.grey.shade800 : null,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: cardBorderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: cardBorderColor),
                            ),
                          ),
                          items:
                              [30, 45, 60, 90, 120]
                                  .map(
                                    (i) => DropdownMenuItem(
                                      value: i,
                                      child: Text('$i'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _updateExerciseDetails(index, 'rest', value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExerciseSelector(BuildContext context, Color primaryColor, Color accentColor) {
    // Local state for filtering the exercises in the bottom sheet
    String exerciseSearchTerm = "";
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final modalBgColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final searchBgColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: modalBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Use a StatefulBuilder to update the search term within the bottom sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Filter exercises based on the search term (case-insensitive)
            final List<Map<String, dynamic>> filteredExercises =
                _gymExercises
                    .where(
                      (exercise) =>
                          exercise['name'].toLowerCase().contains(
                            exerciseSearchTerm.toLowerCase(),
                          ) ||
                          exercise['body_part'].toLowerCase().contains(
                            exerciseSearchTerm.toLowerCase(),
                          ) ||
                          exercise['equipment'].toLowerCase().contains(
                            exerciseSearchTerm.toLowerCase(),
                          ) ||
                          exercise['level'].toLowerCase().contains(
                            exerciseSearchTerm.toLowerCase(),
                          ) ||
                          exercise['type'].toLowerCase().contains(
                            exerciseSearchTerm.toLowerCase(),
                          ),
                    )
                    .toList();

            return Container(
              padding: const EdgeInsets.all(16),
              // Make the bottom sheet taller but not full screen
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Select Exercises',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search box
                  TextField(
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      hintStyle: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                      prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: searchBgColor,
                    ),
                    onChanged: (value) {
                      // Update the search term and rebuild the bottom sheet
                      setModalState(() {
                        exerciseSearchTerm = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Exercise list
                  Expanded(
                    child:
                        _isLoadingExercises
                            ? Center(
                              child: CircularProgressIndicator(
                                color: accentColor,
                              ),
                            )
                            : filteredExercises.isEmpty
                            ? Center(
                              child: Text(
                                'No exercises found',
                                style: TextStyle(color: primaryColor),
                              ),
                            )
                            : ListView.separated(
                              itemCount: filteredExercises.length,
                              separatorBuilder: (context, index) => Divider(
                                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                              ),
                              itemBuilder: (context, index) {
                                final exercise = filteredExercises[index];
                                final bool isAlreadyAdded = _selectedExercises
                                    .any((e) => e['id'] == exercise['id']);

                                return ListTile(
                                  title: Text(
                                    exercise['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${exercise['body_part']} • ${exercise['equipment']} • ${exercise['level']}',
                                    style: TextStyle(
                                      color: isDarkMode 
                                          ? Colors.grey.shade400 
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  trailing:
                                      isAlreadyAdded
                                          ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                          : IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                            ),
                                            color: accentColor,
                                            onPressed: () {
                                              _addExercise(exercise);
                                              Navigator.pop(context);
                                            },
                                          ),
                                  onTap: () {
                                    if (!isAlreadyAdded) {
                                      _addExercise(exercise);
                                      Navigator.pop(context);
                                    }
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

  Widget _buildBottomBar(ThemeData theme, Color primaryColor, Color accentColor) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final bottomBarColor = isDarkMode ? Colors.grey.shade900 : theme.scaffoldBackgroundColor;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bottomBarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
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
              onPressed: _updateWorkout,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: accentColor,
              ),
              child: const Text('Update Workout'),
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
            'Updating your workout...',
            style: TextStyle(color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error Updating Workout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'An unknown error occurred',
              style: const TextStyle(color: Colors.grey),
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
              backgroundColor: Colors.red.shade300,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
