// lib/models/exercise.dart
class Exercise {
  final int id;
  final String name;
  final String description;
  final String type;
  final String bodyPart;
  final String equipment;
  final String level;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ExerciseDetails? pivot;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.bodyPart,
    required this.equipment,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
    this.pivot,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      bodyPart: json['body_part'],
      equipment: json['equipment'],
      level: json['level'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      pivot: json['pivot'] != null ? ExerciseDetails.fromJson(json['pivot']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'body_part': bodyPart,
      'equipment': equipment,
      'level': level,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// lib/models/exercise_details.dart
class ExerciseDetails {
  final int customWorkoutId;
  final int gymExerciseId;
  final int sets;
  final int reps;
  final int? duration;
  final int rest;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExerciseDetails({
    required this.customWorkoutId,
    required this.gymExerciseId,
    required this.sets,
    required this.reps,
    this.duration,
    required this.rest,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseDetails.fromJson(Map<String, dynamic> json) {
    return ExerciseDetails(
      customWorkoutId: json['custom_workout_id'],
      gymExerciseId: json['gym_exercise_id'],
      sets: json['sets'],
      reps: json['reps'],
      duration: json['duration'],
      rest: json['rest'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'custom_workout_id': customWorkoutId,
      'gym_exercise_id': gymExerciseId,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'rest': rest,
    };
  }
}

// lib/models/workout.dart
class Workout {
  final int id;
  final int userId;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Exercise>? exercises;

  Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.exercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      exercises: json['gym_exercises'] != null
          ? List<Exercise>.from(
              json['gym_exercises'].map((x) => Exercise.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// lib/models/scheduled_workout.dart
class ScheduledWorkout {
  final int id;
  final int userId;
  final int workoutId;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Workout? workout;

  ScheduledWorkout({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
    this.workout,
  });

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) {
    return ScheduledWorkout(
      id: json['id'],
      userId: json['user_id'],
      workoutId: json['workout_id'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      workout: json['workout'] != null ? Workout.fromJson(json['workout']) : null,
    );
  }
}

// lib/models/weekly_workout_plan.dart
class WeeklyWorkoutPlan {
  final Map<String, List<ScheduledWorkout>> weeks;

  WeeklyWorkoutPlan({required this.weeks});

  factory WeeklyWorkoutPlan.fromJson(Map<String, dynamic> json) {
    final Map<String, List<ScheduledWorkout>> weeksMap = {};
    
    json.forEach((weekKey, weekData) {
      final weekMap = weekData as Map<String, dynamic>;
      final weekSchedule = <String, List<ScheduledWorkout>>{};
      
      weekMap.forEach((day, workouts) {
        weekSchedule[day] = List<ScheduledWorkout>.from(
          (workouts as List).map((w) => ScheduledWorkout.fromJson(w)));
      });
      
      weeksMap[weekKey] = weekSchedule.values.expand((element) => element).toList();
    });
    
    return WeeklyWorkoutPlan(weeks: weeksMap);
  }
}