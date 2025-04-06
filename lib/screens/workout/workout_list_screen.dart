import 'package:fitness_tracker_app/screens/workout/edit_workout_screen.dart';
import 'package:fitness_tracker_app/screens/workout/new_workout_screen.dart';
import 'package:fitness_tracker_app/screens/workout/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class WorkoutManagementScreen extends StatefulWidget {
  const WorkoutManagementScreen({super.key});

  @override
  _WorkoutManagementScreenState createState() => _WorkoutManagementScreenState();
}

class _WorkoutManagementScreenState extends State<WorkoutManagementScreen> {
  final ApiService _apiService = ApiService();
  
  // Data
  List<Map<String, dynamic>> _workouts = [];
  
  // UI states
  bool _isLoading = true;
  String? _errorMessage;

  // Custom app colors
  late Color _primaryColor;
  late Color _accentColor;

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  Future<void> _fetchWorkouts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<dynamic> workouts = await _apiService.fetchWorkout();
      setState(() {
        _workouts = workouts.map((workout) => workout as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load workouts: ${e.toString()}';
        debugPrint('Failed to load workouts: ${e.toString()}');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteWorkout(int workoutId) async {
    try {
      await _apiService.deleteCustomWorkout(workoutId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchWorkouts(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete workout: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, int workoutId, String workoutName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout?'),
        content: Text('Are you sure you want to delete "$workoutName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteWorkout(workoutId);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateWorkout() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewWorkoutScreen()),
    );

    if (result == true) {
      _fetchWorkouts(); // Refresh the list if a workout was created
    }
  }

  void _navigateToEditWorkout(Map<String, dynamic> workout) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWorkoutScreen(workoutId: workout['id']),
      ),
    );

    if (result == true) {
      _fetchWorkouts(); // Refresh the list if a workout was updated
    }
  }

  void _navigateToWorkoutDetails(Map<String, dynamic> workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(workoutId: workout['id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Initialize custom colors
    _primaryColor = Colors.blueGrey;
    _accentColor = Colors.blue;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Workout Management'),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: _primaryColor.withOpacity(0.1),
        foregroundColor: _primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWorkouts,
            tooltip: 'Refresh workouts',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState(theme)
              : _buildWorkoutsList(theme),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateWorkout,
        backgroundColor: _accentColor,
        child: const Icon(Icons.add),),
    );
  }

  Widget _buildWorkoutsList(ThemeData theme) {
    if (_workouts.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: _fetchWorkouts,
      color: _accentColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _workouts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final workout = _workouts[index];
          return _buildWorkoutCard(theme, workout);
        },
      ),
    );
  }

  Widget _buildWorkoutCard(ThemeData theme, Map<String, dynamic> workout) {
    final exerciseCount = (workout['exercises'] as List?)?.length ?? 0;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToWorkoutDetails(workout),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workout icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: _accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Workout details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout['name'] ?? 'Unnamed Workout',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workout['description'] ?? 'No description',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Row(
                        //   children: [
                        //     _buildWorkoutMetric(
                        //       theme,
                        //       Icons.list_alt,
                        //       '$exerciseCount ${exerciseCount == 1 ? 'exercise' : 'exercises'}',
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              // const Divider(height: 24),
              
              // // Action buttons
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     TextButton.icon(
              //       onPressed: () => _navigateToWorkoutDetails(workout),
              //       icon: Icon(Icons.visibility, size: 18, color: _primaryColor),
              //       label: Text('View', style: TextStyle(color: _primaryColor)),
              //     ),
              //     const SizedBox(width: 8),
              //     TextButton.icon(
              //       onPressed: () => _navigateToEditWorkout(workout),
              //       icon: Icon(Icons.edit, size: 18, color: _accentColor),
              //       label: Text('Edit', style: TextStyle(color: _accentColor)),
              //     ),
              //     const SizedBox(width: 8),
              //     TextButton.icon(
              //       onPressed: () => _showDeleteConfirmation(
              //         context,
              //         workout['id'],
              //         workout['name'] ?? 'Unnamed Workout',
              //       ),
              //       icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              //       label: const Text('Delete', style: TextStyle(color: Colors.red)),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutMetric(ThemeData theme, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: _primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Workouts Yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first workout to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _navigateToCreateWorkout,
            icon: const Icon(Icons.add),
            label: const Text('Create New Workout'),
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
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
            'Loading workouts...',
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
            'Error Loading Workouts',
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
            onPressed: _fetchWorkouts,
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


// Ensure you have this API method in your ApiService class
/**
class ApiService {
  // ... existing methods
  
  Future<List<dynamic>> getCustomWorkouts() async {
    // Implement API call to get all custom workouts
  }
  
  Future<void> deleteCustomWorkout(int workoutId) async {
    // Implement API call to delete a workout
  }
  
  Future<void> updateCustomWorkout(
    int workoutId, 
    String name, 
    String description, 
    List<Map<String, dynamic>> exercises
  ) async {
    // Implement API call to update an existing workout
  }
}
**/