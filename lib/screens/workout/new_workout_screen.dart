import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NewWorkoutScreen extends StatefulWidget {
  const NewWorkoutScreen({super.key});

  @override
  _NewWorkoutScreenState createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Selected exercises
  List<Map<String, dynamic>> _selectedExercises = [];

  // List of available exercises
  List<Map<String, dynamic>> _gymExercises = [];

  // UI states
  bool _isLoading = false;
  bool _isLoadingExercises = true;
  String? _errorMessage;

  // App colors - updated for dark theme compatibility
  late Color _primaryColor;
  late Color _accentColor;
  late Color _cardColor;
  late Color _surfaceColor;
  late Color _textPrimaryColor;
  late Color _textSecondaryColor;
  late Color _borderColor;
  late Color _errorColor;

  @override
  void initState() {
    super.initState();
    _fetchGymExercises();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Initialize colors based on the current theme
  void _initializeColors(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    _primaryColor = isDark ? Colors.blueGrey.shade600 : Colors.blueGrey;
    _accentColor = isDark ? Colors.tealAccent.shade700 : Colors.blue;
    _cardColor = isDark ? Colors.grey.shade900 : theme.cardColor;
    _surfaceColor = isDark ? Colors.grey.shade800 : theme.colorScheme.surfaceVariant;
    _textPrimaryColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    _textSecondaryColor = isDark ? Colors.grey.shade300 : theme.colorScheme.onSurfaceVariant;
    _borderColor = isDark ? Colors.grey.shade700 : theme.colorScheme.outlineVariant.withOpacity(0.5);
    _errorColor = isDark ? Colors.red.shade300 : Colors.red;
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

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one exercise to your workout'),
          backgroundColor: _errorColor,
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

      await _apiService.storeCustomWorkout(name, description, gymExercises);

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
    
    // Initialize colors based on current theme
    _initializeColors(theme);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Create New Workout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _textPrimaryColor,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: _textPrimaryColor,
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
                    color: _accentColor,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: _accentColor),
            onPressed: _fetchGymExercises,
            tooltip: 'Refresh exercise list',
          ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
              ? _buildErrorState(theme)
              : _buildForm(theme),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(theme),
            const SizedBox(height: 24),
            _buildExercisesSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _accentColor,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          style: TextStyle(color: _textPrimaryColor),
          decoration: InputDecoration(
            labelText: 'Workout Name',
            labelStyle: TextStyle(color: _textSecondaryColor),
            hintText: 'e.g., Upper Body Strength',
            hintStyle: TextStyle(color: _textSecondaryColor.withOpacity(0.7)),
            filled: true,
            fillColor: _surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _accentColor, width: 2),
            ),
            prefixIcon: Icon(Icons.fitness_center, color: _accentColor),
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
          style: TextStyle(color: _textPrimaryColor),
          decoration: InputDecoration(
            labelText: 'Description',
            labelStyle: TextStyle(color: _textSecondaryColor),
            hintText: 'Focus of this workout, target muscle groups, etc.',
            hintStyle: TextStyle(color: _textSecondaryColor.withOpacity(0.7)),
            filled: true,
            fillColor: _surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _accentColor, width: 2),
            ),
            prefixIcon: Icon(Icons.description, color: _accentColor),
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

  Widget _buildExercisesSection(ThemeData theme) {
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
                color: _accentColor,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showExerciseSelector(context),
              icon: Icon(Icons.add, color: _accentColor),
              label: Text(
                'Add Exercise',
                style: TextStyle(color: _accentColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add exercises and configure sets, reps, and rest periods',
          style: TextStyle(color: _textSecondaryColor),
        ),
        const SizedBox(height: 16),

        // Selected exercises list
        _selectedExercises.isEmpty
            ? _buildEmptyExercisesState(theme)
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedExercises.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final exercise = _selectedExercises[index];
                return _buildExerciseCard(theme, exercise, index);
              },
            ),
      ],
    );
  }

  Widget _buildEmptyExercisesState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: _accentColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No exercises added yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _accentColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add exercises to create your custom workout',
              style: TextStyle(color: _textSecondaryColor),
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
  ) {
    return Card(
      elevation: 4,
      color: _cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _borderColor),
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
                          color: _textPrimaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exercise['body_part']} • ${exercise['level']}',
                        style: TextStyle(color: _textSecondaryColor),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: _errorColor),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildDropdown(
                        theme,
                        value: exercise['sets'],
                        items: List.generate(10, (i) => i + 1),
                        onChanged: (value) {
                          if (value != null) {
                            _updateExerciseDetails(index, 'sets', value);
                          }
                        },
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildDropdown(
                        theme,
                        value: exercise['reps'],
                        items: [8, 10, 12, 15, 20],
                        onChanged: (value) {
                          if (value != null) {
                            _updateExerciseDetails(index, 'reps', value);
                          }
                        },
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildDropdown(
                        theme,
                        value: exercise['rest'],
                        items: [30, 45, 60, 90, 120],
                        onChanged: (value) {
                          if (value != null) {
                            _updateExerciseDetails(index, 'rest', value);
                          }
                        },
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

  // Helper method for consistent dropdowns
  Widget _buildDropdown(
    ThemeData theme, {
    required int value,
    required List<int> items,
    required Function(int?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
        color: _surfaceColor,
      ),
      child: DropdownButtonFormField<int>(
        value: value,
        dropdownColor: _cardColor,
        style: TextStyle(color: _textPrimaryColor),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        icon: Icon(Icons.arrow_drop_down, color: _accentColor),
        items: items
            .map(
              (i) => DropdownMenuItem(
                value: i,
                child: Text('$i'),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showExerciseSelector(BuildContext context) {
    // Local state for filtering the exercises in the bottom sheet
    String exerciseSearchTerm = "";
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
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
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Select Exercises',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _accentColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: _textPrimaryColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search box
                  TextField(
                    style: TextStyle(color: _textPrimaryColor),
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      hintStyle: TextStyle(color: _textSecondaryColor),
                      prefixIcon: Icon(Icons.search, color: _accentColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _accentColor, width: 2),
                      ),
                      filled: true,
                      fillColor: _surfaceColor,
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
                                color: _accentColor,
                              ),
                            )
                            : filteredExercises.isEmpty
                            ? Center(
                              child: Text(
                                'No exercises found',
                                style: TextStyle(color: _accentColor),
                              ),
                            )
                            : ListView.separated(
                              itemCount: filteredExercises.length,
                              separatorBuilder:
                                  (context, index) => Divider(color: _borderColor),
                              itemBuilder: (context, index) {
                                final exercise = filteredExercises[index];
                                final bool isAlreadyAdded = _selectedExercises
                                    .any((e) => e['id'] == exercise['id']);

                                return ListTile(
                                  title: Text(
                                    exercise['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _textPrimaryColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${exercise['body_part']} • ${exercise['equipment']} • ${exercise['level']}',
                                    style: TextStyle(color: _textSecondaryColor),
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
                                            color: _accentColor,
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

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
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
                side: BorderSide(color: _accentColor),
              ),
              child: Text('Cancel', style: TextStyle(color: _accentColor)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: _saveWorkout,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: _accentColor,
              ),
              child: const Text('Save Workout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _accentColor),
          const SizedBox(height: 16),
          Text(
            'Saving your workout...',
            style: TextStyle(color: _accentColor),
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
          Icon(Icons.error_outline, size: 64, color: _errorColor),
          const SizedBox(height: 16),
          Text(
            'Error Creating Workout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'An unknown error occurred',
              style: TextStyle(color: _textSecondaryColor),
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
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}