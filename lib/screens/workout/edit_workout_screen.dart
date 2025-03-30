// lib/screens/workout/edit_workout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const EditWorkoutScreen({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  _EditWorkoutScreenState createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  
  late List<Map<String, dynamic>> _selectedExercises;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workout.name);
    _descriptionController = TextEditingController(text: widget.workout.description);
    
    // Convert exercises to required format
    _selectedExercises = widget.workout.exercises?.map((e) {
      final pivot = e.pivot!;
      return {
        'gym_exercise_id': e.id,
        'name': e.name,
        'sets': pivot.sets,
        'reps': pivot.reps,
        'duration': pivot.duration,
        'rest': pivot.rest,
      };
    }).toList() ?? [];
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _updateWorkout() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise to your workout'),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final workout = await Provider.of<WorkoutProvider>(context, listen: false).updateCustomWorkout(
        widget.workout.id,
        _nameController.text,
        _descriptionController.text,
        _selectedExercises,
      );
      
      Navigator.of(context).pop(workout);
        } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
        } finally {
      setState(() {
        _isLoading = false;
      });
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Workout'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Workout Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a workout name';
              }
              return null;
            },
              ),
              TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
            onPressed: _updateWorkout,
            child: const Text('Save Changes'),
              ),
            ],
          ),
            ),
          ),
        ),
        );
      }
    }