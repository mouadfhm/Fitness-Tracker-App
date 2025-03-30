// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final int workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late Future<Map<String, dynamic>> _workoutFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchWorkoutDetails();
  }

  void _fetchWorkoutDetails() {
    setState(() {
      _workoutFuture = _apiService.fetchCustomWorkout(widget.workoutId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWorkoutDetails,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _workoutFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchWorkoutDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No workout details available'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchWorkoutDetails,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          final workout = snapshot.data!;
          final exercises = workout['gym_exercises'] as List<dynamic>;

          return CustomScrollView(
            slivers: [
              // Workout header section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        workout['description'] ?? 'No description available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Chip(
                            label: Text('${exercises.length} Exercises'),
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(_calculateTotalTime(exercises)),
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      const Text(
                        'Exercises',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // List of exercises
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = exercises[index];
                    final pivot = exercise['pivot'];
                    
                    return ExerciseCard(
                      exercise: exercise,
                      sets: pivot['sets'],
                      reps: pivot['reps'],
                      duration: pivot['duration'],
                      rest: pivot['rest'],
                    );
                  },
                  childCount: exercises.length,
                ),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to start workout screen
          // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => 
          //   StartWorkoutScreen(workoutId: widget.workoutId)));
        },
        icon: const Icon(Icons.fitness_center),
        label: const Text('Start Workout'),
      ),
    );
  }

  String _calculateTotalTime(List<dynamic> exercises) {
    // Calculate estimated workout time based on sets, reps, and rest periods
    int totalTimeInSeconds = 0;
    
    for (var exercise in exercises) {
      final pivot = exercise['pivot'];
      final sets = pivot['sets'] as int;
      final rest = pivot['rest'] as int;
      
      // Estimate 3 seconds per rep
      int repsTime = 0;
      if (pivot['reps'] != null) {
        repsTime = (pivot['reps'] as int) * 3 * sets;
      } else if (pivot['duration'] != null) {
        repsTime = (pivot['duration'] as int) * sets;
      }
      
      // Add rest time between sets (except after the last set)
      int restTime = rest * (sets - 1);
      
      totalTimeInSeconds += repsTime + restTime;
    }
    
    // Convert to minutes
    int minutes = totalTimeInSeconds ~/ 60;
    return '$minutes min';
  }
}

class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final int sets;
  final int? reps;
  final int? duration;
  final int rest;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.rest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          exercise['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${exercise['body_part']} • ${exercise['type']}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildDetailChip(Icons.replay, '$sets sets'),
                const SizedBox(width: 8),
                if (reps != null)
                  _buildDetailChip(Icons.fitness_center, '$reps reps')
                else if (duration != null)
                  _buildDetailChip(Icons.timer, '${duration}s'),
                const SizedBox(width: 8),
                _buildDetailChip(Icons.hourglass_bottom, '${rest}s rest'),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise['description'] ?? 'No description available',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Equipment: ${exercise['equipment']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Level: ${exercise['level']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.videocam),
                    label: const Text('Watch Technique'),
                    onPressed: () {
                      // Navigate to video tutorial if available
                      // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => 
                      //   ExerciseTutorialScreen(exerciseId: exercise['id'])));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}