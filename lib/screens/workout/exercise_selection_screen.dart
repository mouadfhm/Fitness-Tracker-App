// lib/screens/workout/exercise_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout.dart';

class ExerciseSelectionScreen extends StatefulWidget {
  const ExerciseSelectionScreen({super.key});

  @override
  _ExerciseSelectionScreenState createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  String _selectedBodyPart = 'All';
  Exercise? _selectedExercise;
  
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '12');
  final _durationController = TextEditingController();
  final _restController = TextEditingController(text: '60');
  
  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _restController.dispose();
    super.dispose();
  }
  
  List<String> _getUniqueBodyParts(List<Exercise> exercises) {
    final bodyParts = exercises.map((e) => e.bodyPart).toSet().toList();
    bodyParts.sort();
    return ['All', ...bodyParts];
  }
  
  List<Exercise> _filterExercises(List<Exercise> exercises) {
    if (_selectedBodyPart == 'All') {
      return exercises;
    }
    return exercises.where((e) => e.bodyPart == _selectedBodyPart).toList();
  }
  
  void _addExercise() {
    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an exercise'),
        ),
      );
      return;
    }
    
    final sets = int.tryParse(_setsController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 0;
    final rest = int.tryParse(_restController.text) ?? 0;
    
    if (sets <= 0 || reps <= 0 || rest <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid values for sets, reps, and rest'),
        ),
      );
      return;
    }
    
    int? duration;
    if (_durationController.text.isNotEmpty) {
      duration = int.tryParse(_durationController.text);
      if (duration != null && duration <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid duration or leave it empty'),
          ),
        );
        return;
      }
    }
    
    final exerciseData = {
      'gym_exercise_id': _selectedExercise!.id,
      'name': _selectedExercise!.name,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'rest': rest,
    };
    
    Navigator.of(context).pop(exerciseData);
  }
  
  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final exercises = workoutProvider.exercises;
    final filteredExercises = _filterExercises(exercises);
    final bodyParts = _getUniqueBodyParts(exercises);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercise'),
      ),
      body: workoutProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Filter by Body Part:'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          value: _selectedBodyPart,
                          isExpanded: true,
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedBodyPart = newValue!;
                              _selectedExercise = null;
                            });
                          },
                          items: bodyParts
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredExercises.isEmpty
                      ? const Center(
                          child: Text('No exercises found'),
                        )
                      : ListView.builder(
                          itemCount: filteredExercises.length,
                          itemBuilder: (ctx, index) {
                            final exercise = filteredExercises[index];
                            return RadioListTile<Exercise>(
                              title: Text(exercise.name),
                              subtitle: Text(
                                '${exercise.type} | ${exercise.bodyPart} | ${exercise.equipment}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              value: exercise,
                              groupValue: _selectedExercise,
                              onChanged: (Exercise? value) {
                                setState(() {
                                  _selectedExercise = value;
                                });
                              },
                            );
                          },
                        ),
                ),
                if (_selectedExercise != null)
                  Container(
                    color: Theme.of(context).cardColor,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedExercise!.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedExercise!.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _setsController,
                                decoration: const InputDecoration(
                                  labelText: 'Sets',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _repsController,
                                decoration: const InputDecoration(
                                  labelText: 'Reps',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _durationController,
                                decoration: const InputDecoration(
                                  labelText: 'Duration (sec)',
                                  hintText: 'Optional',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _restController,
                                decoration: const InputDecoration(
                                  labelText: 'Rest (sec)',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addExercise,
                            child: const Text('Add to Workout'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

