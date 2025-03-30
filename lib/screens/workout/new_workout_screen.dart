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

  // Custom app colors
  late Color _primaryColor;
  late Color _accentColor;

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

Future<void> _fetchGymExercises() async {
  setState(() {
    _isLoadingExercises = true;
    _errorMessage = null;
  });

  try {
    final List<dynamic> exercises = await _apiService.getGymExercises();
    setState(() {
      _gymExercises = exercises.map((exercise) {
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

    // Initialize custom colors to match workout calendar screen
    _primaryColor = Colors.blueGrey;
    _accentColor = Colors.blue;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Create New Workout'),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: _primaryColor.withOpacity(0.1),
        foregroundColor: _primaryColor,
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
                    color: _primaryColor,
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
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Workout Name',
            hintText: 'e.g., Upper Body Strength',
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            prefixIcon: Icon(Icons.fitness_center, color: _primaryColor),
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
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Focus of this workout, target muscle groups, etc.',
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            prefixIcon: Icon(Icons.description, color: _primaryColor),
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
                color: _primaryColor,
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
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
              color: _primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No exercises added yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add exercises to create your custom workout',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
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
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exercise['body_part']} • ${exercise['level']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: exercise['sets'],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: exercise['reps'],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: exercise['rest'],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
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

void _showExerciseSelector(BuildContext context) {
  // Local state for filtering the exercises in the bottom sheet
  String exerciseSearchTerm = "";
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      // Use a StatefulBuilder to update the search term within the bottom sheet
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          // Filter exercises based on the search term (case-insensitive)
            final List<Map<String, dynamic>> filteredExercises = _gymExercises
              .where((exercise) =>
                exercise['name'].toLowerCase().contains(exerciseSearchTerm.toLowerCase()) ||
                exercise['body_part'].toLowerCase().contains(exerciseSearchTerm.toLowerCase()) ||
                exercise['equipment'].toLowerCase().contains(exerciseSearchTerm.toLowerCase()) ||
                exercise['level'].toLowerCase().contains(exerciseSearchTerm.toLowerCase()) ||
                exercise['type'].toLowerCase().contains(exerciseSearchTerm.toLowerCase()) )
              .toList();
          
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Select Exercises',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
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
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
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
                  child: _isLoadingExercises
                      ? Center(
                          child: CircularProgressIndicator(
                            color: _accentColor,
                          ),
                        )
                      : filteredExercises.isEmpty
                          ? Center(
                              child: Text(
                                'No exercises found',
                                style: TextStyle(color: _primaryColor),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredExercises.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                final exercise = filteredExercises[index];
                                final bool isAlreadyAdded = _selectedExercises
                                    .any((e) => e['id'] == exercise['id']);
                                
                                return ListTile(
                                  title: Text(
                                    exercise['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${exercise['body_part']} • ${exercise['equipment']} • ${exercise['level']}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  trailing: isAlreadyAdded
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline),
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
            color: Colors.black.withOpacity(0.05),
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
                side: BorderSide(color: _primaryColor),
              ),
              child: Text('Cancel', style: TextStyle(color: _primaryColor)),
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
            style: TextStyle(color: _primaryColor),
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
            'Error Creating Workout',
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
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
