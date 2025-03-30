// lib/services/workout_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout.dart';
import 'token_service.dart';

class WorkoutService {
  final String baseUrl;

  WorkoutService({required this.baseUrl});

  Future<List<Exercise>> getGymExercises() async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/exercises/search'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Exercise>.from(data['gym_exercises'].map((x) => Exercise.fromJson(x)));
    } else {
      throw Exception('Failed to load exercises: ${response.body}');
    }
  }

  Future<Workout> storeCustomWorkout(
    String name,
    String description,
    List<Map<String, dynamic>> gymExercises,
  ) async {
    final token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/v2/workouts/custom-workouts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'gym_exercises': gymExercises,
      }),
    );

    if (response.statusCode == 200) {
      return Workout.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to store custom workout: ${response.body}');
    }
  }

  Future<Workout> updateCustomWorkout(
    int workoutId,
    String name,
    String description,
    List<Map<String, dynamic>> gymExercises,
  ) async {
    final token = await TokenService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/v2/workouts/custom-workouts/$workoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'gym_exercises': gymExercises,
      }),
    );

    if (response.statusCode == 200) {
      return Workout.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update custom workout: ${response.body}');
    }
  }

  Future<Workout> fetchCustomWorkout(int workoutId) async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/custom-workouts/$workoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Workout.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch custom workout: ${response.body}');
    }
  }

  Future<ScheduledWorkout> storeScheduleWorkout(
    int workoutId,
    DateTime scheduledAt,
  ) async {
    final token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/v2/workouts/scheduled-workouts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'workout_id': workoutId,
        'scheduled_at': scheduledAt.toIso8601String().split('T').join(' ').split('.')[0],
      }),
    );

    if (response.statusCode == 200) {
      return ScheduledWorkout.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to store scheduled workout: ${response.body}');
    }
  }

  Future<ScheduledWorkout> updateScheduleWorkout(
    int scheduleWorkoutId,
    DateTime scheduledAt,
  ) async {
    final token = await TokenService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/v2/workouts/scheduled-workouts/$scheduleWorkoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'scheduled_at': scheduledAt.toIso8601String().split('T').join(' ').split('.')[0],
      }),
    );

    if (response.statusCode == 200) {
      return ScheduledWorkout.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update scheduled workout: ${response.body}');
    }
  }

  Future<ScheduledWorkout> fetchScheduleWorkout(int scheduleWorkoutId) async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/scheduled-workouts/$scheduleWorkoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return ScheduledWorkout.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch scheduled workout: ${response.body}');
    }
  }

  Future<WeeklyWorkoutPlan> storeWeeklyWorkouts(
    DateTime startDate,
    int weeks,
    Map<String, int?> daysPattern,
  ) async {
    final token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/v2/workouts/weekly-cycle-plans'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'start_date': startDate.toIso8601String().split('T')[0],
        'weeks': weeks,
        'days_pattern': daysPattern,
      }),
    );

    if (response.statusCode == 200) {
      return WeeklyWorkoutPlan.fromJson(jsonDecode(response.body)['weeks']);
    } else {
      throw Exception('Failed to store weekly workouts: ${response.body}');
    }
  }

  Future<WeeklyWorkoutPlan> fetchWeeklyWorkouts() async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/weekly-cycle-plans'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return WeeklyWorkoutPlan.fromJson(jsonDecode(response.body)['weeks']);
    } else {
      throw Exception('Failed to fetch weekly workouts: ${response.body}');
    }
  }
}