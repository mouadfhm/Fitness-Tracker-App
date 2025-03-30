// lib/providers/workout_provider.dart
import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';

class WorkoutProvider with ChangeNotifier {
  final WorkoutService _workoutService;
  
  List<Exercise> _exercises = [];
  List<Workout> _workouts = [];
  WeeklyWorkoutPlan? _weeklyPlan;
  bool _isLoading = false;
  String? _errorMessage;

  WorkoutProvider({required WorkoutService workoutService})
      : _workoutService = workoutService;

  // Getters
  List<Exercise> get exercises => _exercises;
  List<Workout> get workouts => _workouts;
  WeeklyWorkoutPlan? get weeklyPlan => _weeklyPlan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Fetch exercises
  Future<void> fetchExercises() async {
    _setLoading(true);
    try {
      _exercises = await _workoutService.getGymExercises();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load exercises: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Filter exercises by body part
  List<Exercise> getExercisesByBodyPart(String bodyPart) {
    return _exercises.where((exercise) => exercise.bodyPart == bodyPart).toList();
  }
  
  // Create custom workout
  Future<Workout?> createCustomWorkout(
    String name,
    String description,
    List<Map<String, dynamic>> gymExercises,
  ) async {
    _setLoading(true);
    try {
      final workout = await _workoutService.storeCustomWorkout(
        name,
        description,
        gymExercises,
      );
      _workouts.add(workout);
      notifyListeners();
      return workout;
    } catch (e) {
      _setError('Failed to create workout: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update custom workout
  Future<Workout?> updateCustomWorkout(
    int workoutId,
    String name,
    String description,
    List<Map<String, dynamic>> gymExercises,
  ) async {
    _setLoading(true);
    try {
      final workout = await _workoutService.updateCustomWorkout(
        workoutId,
        name,
        description,
        gymExercises,
      );
      
      final index = _workouts.indexWhere((w) => w.id == workoutId);
      if (index != -1) {
        _workouts[index] = workout;
      }
      
      notifyListeners();
      return workout;
    } catch (e) {
      _setError('Failed to update workout: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch custom workout
  Future<Workout?> fetchCustomWorkout(int workoutId) async {
    _setLoading(true);
    try {
      final workout = await _workoutService.fetchCustomWorkout(workoutId);
      notifyListeners();
      return workout;
    } catch (e) {
      _setError('Failed to fetch workout: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Schedule a workout
  Future<ScheduledWorkout?> scheduleWorkout(
    int workoutId,
    DateTime scheduledAt,
  ) async {
    _setLoading(true);
    try {
      final scheduledWorkout = await _workoutService.storeScheduleWorkout(
        workoutId,
        scheduledAt,
      );
      
      // Refresh weekly plan if exists
      if (_weeklyPlan != null) {
        await fetchWeeklyWorkouts();
      }
      
      notifyListeners();
      return scheduledWorkout;
    } catch (e) {
      _setError('Failed to schedule workout: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update scheduled workout
  Future<ScheduledWorkout?> updateScheduledWorkout(
    int scheduleWorkoutId,
    DateTime scheduledAt,
  ) async {
    _setLoading(true);
    try {
      final scheduledWorkout = await _workoutService.updateScheduleWorkout(
        scheduleWorkoutId,
        scheduledAt,
      );
      
      // Refresh weekly plan if exists
      if (_weeklyPlan != null) {
        await fetchWeeklyWorkouts();
      }
      
      notifyListeners();
      return scheduledWorkout;
    } catch (e) {
      _setError('Failed to update scheduled workout: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Create weekly workout plan
  Future<bool> createWeeklyPlan(
    DateTime startDate,
    int weeks,
    Map<String, int?> daysPattern,
  ) async {
    _setLoading(true);
    try {
      _weeklyPlan = await _workoutService.storeWeeklyWorkouts(
        startDate,
        weeks,
        daysPattern,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create weekly plan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch weekly workout plan
  Future<void> fetchWeeklyWorkouts() async {
    _setLoading(true);
    try {
      _weeklyPlan = await _workoutService.fetchWeeklyWorkouts();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch weekly workouts: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Get workouts for a specific day
  List<ScheduledWorkout> getWorkoutsForDay(DateTime date) {
    if (_weeklyPlan == null) return [];
    
    final weekNumber = _getWeekNumber(date);
    final workoutsForWeek = _weeklyPlan!.weeks[weekNumber.toString()];
    
    if (workoutsForWeek == null) return [];
    
    return workoutsForWeek
        .where((workout) => 
            workout.scheduledAt.year == date.year &&
            workout.scheduledAt.month == date.month &&
            workout.scheduledAt.day == date.day)
        .toList();
  }
  
  // Helper to get ISO week number
  int _getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(
        DateTime(date.year, date.month, date.day)
            .difference(DateTime(date.year, 1, 1))
            .inDays
            .toString()) +
        1;
    int weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
    return weekNumber;
  }
}