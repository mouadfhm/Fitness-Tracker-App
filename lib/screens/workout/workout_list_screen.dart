// lib/screens/workout/workout_list_screen.dart
import 'package:fitness_tracker_app/screens/workout/workout_calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout.dart';
import 'workout_detail_screen.dart';
import 'new_workout_screen.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({Key? key}) : super(key: key);

  @override
  _WorkoutListScreenState createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<WorkoutProvider>(context, listen: false).fetchExercises();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final workouts = workoutProvider.workouts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const WorkoutCalendarScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body:
          workoutProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : workoutProvider.errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'An error occurred:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(workoutProvider.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        workoutProvider.clearError();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
              : workouts.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No workouts yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create your first workout to get started!',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (ctx, index) {
                  final workout = workouts[index];
                  return WorkoutItem(workout: workout);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const NewWorkoutScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class WorkoutItem extends StatelessWidget {
  final Workout workout;

  const WorkoutItem({Key? key, required this.workout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final exerciseCount = workout.exercises?.length ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => WorkoutDetailScreen(workoutId: workout.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workout.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      _showScheduleDialog(context, workout);
                    },
                    tooltip: 'Schedule this workout',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                workout.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '$exerciseCount exercises',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleDialog(BuildContext context, Workout workout) {
    final workoutProvider = Provider.of<WorkoutProvider>(
      context,
      listen: false,
    );
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Schedule Workout'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('When would you like to do "${workout.name}"?'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      selectedDate = picked;
                    }
                  },
                  child: const Text('Select Date'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await workoutProvider.scheduleWorkout(
                    workout.id,
                    selectedDate,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout scheduled successfully!'),
                      ),
                    );
                  }
                },
                child: const Text('Schedule'),
              ),
            ],
          ),
    );
  }
}
