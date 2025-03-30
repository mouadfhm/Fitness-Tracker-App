import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_service.dart'; // Import the new token service
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['BASE_URL']!;
  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": confirmPassword,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Save token using TokenService
      if (data.containsKey('access_token')) {
        await TokenService.saveToken(data['access_token']);
      }
      return data;
    } else {
      throw Exception("Failed to register: ${response.body}");
    }
  }

  // POST request for login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save token using TokenService
      if (data.containsKey('access_token')) {
        await TokenService.saveToken(data['access_token']);
      }
      return data;
    } else {
      throw Exception("Failed to login: ${response.body}");
    }
  }

  /// Optional: clear token on logout
  Future<void> logout() async {
    await TokenService.deleteToken();
  }

  // Example: GET profile
  Future<Map<String, dynamic>> getProfile() async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load profile: ${response.body}");
    }
  }

  // update profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final token = await TokenService.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/profile'), // Adjust the endpoint if needed
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  //Update goal
  Future<Map<String, dynamic>> updateGoal(Map<String, dynamic> data) async {
    final token = await TokenService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/goals/'), // Adjust the endpoint if needed
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store goal: ${response.body}');
    }
  }

  // get Goal
  Future<Map<String, dynamic>> getGoal() async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/goals/search'), // Adjust the endpoint if needed
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get goal: ${response.body}');
    }
  }

  // get Macros
  Future<Map<String, dynamic>> getMacros() async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/meals/macros'), // Adjust the endpoint if needed
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get meals: ${response.body}');
    }
  }

  //get calories burned
  Future<double> getCalories(String date) async {
    final token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/workouts/calories-burned'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'workout_date': date}),
    );

    if (response.statusCode == 200) {
      // Parse the direct number response
      final dynamic decodedResponse = jsonDecode(response.body);
      // Convert to double, regardless of whether it's returned as int or double
      return (decodedResponse as num).toDouble();
    } else {
      throw Exception('Failed to get calories: ${response.body}');
    }
  }

  // get foods
  Future<List<dynamic>> getFoods() async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/foods/search'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Expecting a JSON array of foods
    } else {
      throw Exception('Failed to load foods');
    }
  }

  // add food
  Future<Map<String, dynamic>> addFood(
    String name,
    double calories,
    double protein,
    double carbs,
    double fat,
  ) async {
    final token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/foods/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'protein': protein,
        'carbs': carbs,
        'fats': fat,
        'calories': calories,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add food: ${response.body}');
    }
  }

  // add favorite food
  Future<Map<String, dynamic>> addFavoriteFood(int foodId) async {
    final token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/foods/favorite/$foodId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add favorite food: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> removeFavoriteFood(int foodId) async {
    final token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/foods/remove-favorite/$foodId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add favorite food: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> storeMeal(
    String name,
    double quantity,
    String? mealTime,
    String date,
  ) async {
    final token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/meals/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'date': date,
        'meal_time': mealTime,
        'foods': [
          {'name': name, 'quantity': quantity},
        ],
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store meal: ${response.body}');
    }
  }

  Future<List<dynamic>> getMeals() async {
    final token = await TokenService.getToken();
    // If a date is provided, you can include it as a query parameter for filtering.
    final uri = Uri.parse('$baseUrl/meals/search');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      ); // Expecting a JSON array of grouped meals
    } else {
      throw Exception('Failed to load meals by date');
    }
  }

  //updateFoodInMeal
  Future<Map<String, dynamic>> updateFoodInMeal(
    int mealId,
    DateTime date,
    String mealTime,
    int foodId,
    double quantity,
  ) async {
    final token = await TokenService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/meals/$mealId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'meal_time': mealTime,
        'date': date,
        'foods': [
          {'food_id': foodId, 'quantity': quantity},
        ],
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update food in meal: ${response.body}');
    }
  }

  // removeFoodFromMeal
  Future<Map<String, dynamic>> removeFoodFromMeal(int mealId) async {
    final token = await TokenService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/meals/$mealId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to remove food from meal: ${response.body}');
    }
  }

  //get exercice
  Future<List<dynamic>> getExercices() async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/workouts/exercises'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      ); // Expecting a JSON array of grouped meals
    } else {
      throw Exception('Failed to load exercices by date');
    }
  }

  //store workout
  Future<Map<String, dynamic>> storeWorkout(
    String activityType,
    int duration,
    String date,
  ) async {
    final token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/workouts/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'workout_date': date,
        'activity_type': activityType,
        'duration': duration,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store workout: ${response.body}');
    }
  }

  // Fetch progress entries
  Future<List<dynamic>> getProgress() async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/progress'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Assuming the API returns a JSON array
    } else {
      throw Exception('Failed to load progress: ${response.body}');
    }
  }

  // Add a progress entry
  Future<void> addProgress(String date, double weight) async {
    final token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/progress/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'date': date, 'weight': weight}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add progress: ${response.body}');
    }
  }

  Future<String?> getToken() async {
    return await TokenService.getToken();
  }

  //get achievements
  Future<List<dynamic>> getAchievements() async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/achievements'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load achievements: ${response.body}');
    }
  }

  Future<List<dynamic>> getUserAchievements() async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/user/achievements'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load achievements: ${response.body}');
    }
  }

Future<List<dynamic>> getGymExercises() async {
  final token = await TokenService.getToken();
  final response = await http.get(
    Uri.parse('$baseUrl/v2/workouts/exercises/search'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  
  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    // Assuming your JSON looks like: { "gym_exercises": [ ... ] }
    return decoded['gym_exercises'] as List<dynamic>;
  } else {
    throw Exception('Failed to load exercises: ${response.body}');
  }
}

  Future<List<dynamic>> storeCustomWorkout(
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
      // "name": "back Workout",
      // "description": "A custom workout routine focusing on back and biceps.",
      // "gym_exercises": [
      //   {
      //     "gym_exercise_id": 1633,
      //     "sets": 3,
      //     "reps": 12,
      //     "duration": null,
      //     "rest": 60
      //   },
      //   {
      //     "gym_exercise_id": 1533,
      //     "sets": 3,
      //     "reps": 12,
      //     "duration": null,
      //     "rest": 60
      //   },
      //   {
      //     "gym_exercise_id": 699,
      //     "sets": 4,
      //     "reps": 10,
      //     "duration": null,
      //     "rest": 90
      //   }
      // ]
    );

    if (response.statusCode == 200|| response.statusCode == 201) {
      return jsonDecode(response.body) ;
    } else {
      throw Exception('Failed to store custom workout: ${response.body}');
    }
  }

  // update customWorkout
  Future<Map<String, dynamic>> updateCustomWorkout(
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

    if (response.statusCode == 200|| response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update custom workout: ${response.body}');
    }
  }

  // fetch customWorkout
  Future<Map<String, dynamic>> fetchCustomWorkout(int workoutId) async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/custom-workouts/$workoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // output:        {
    //     "id": 1,
    //     "user_id": 2,
    //     "name": "chest Workout",
    //     "description": "A custom workout routine focusing on chest and triceps.",
    //     "created_at": "2025-03-29T21:08:45.000000Z",
    //     "updated_at": "2025-03-29T21:08:45.000000Z",
    //     "gym_exercises": [
    //         {
    //             "id": 941,
    //             "name": "TBS Close-Grip Bench Press",
    //             "description": "The close-grip bench pressis a compound exercise targeting the triceps and chest. The main difference between this exercise and the standard bench press is that the hands and elbows are placed closer together.",
    //             "type": "Strength",
    //             "body_part": "Chest",
    //             "equipment": "Barbell",
    //             "level": "Intermediate",
    //             "created_at": "2025-03-29T21:08:14.000000Z",
    //             "updated_at": "2025-03-29T21:08:14.000000Z",
    //             "pivot": {
    //                 "custom_workout_id": 1,
    //                 "gym_exercise_id": 941,
    //                 "sets": 3,
    //                 "reps": 12,
    //                 "duration": null,
    //                 "rest": 60,
    //                 "created_at": "2025-03-29T21:08:45.000000Z",
    //                 "updated_at": "2025-03-29T21:08:45.000000Z"
    //             }
    //         },
    //         {
    //             "id": 2838,
    //             "name": "TBS Rope Cable Push-Down",
    //             "description": "The cable rope push-down is a popular exercise targeting the triceps muscles. It's easy to learn and perform, making it a favorite for everyone from beginners to advanced lifters. It is usually performed for moderate to high reps, such as 8-12 reps or more per set, as part of an upper-body or arm-focused workout.",
    //             "type": "Strength",
    //             "body_part": "Triceps",
    //             "equipment": "Cable",
    //             "level": "Intermediate",
    //             "created_at": "2025-03-29T21:08:35.000000Z",
    //             "updated_at": "2025-03-29T21:08:35.000000Z",
    //             "pivot": {
    //                 "custom_workout_id": 1,
    //                 "gym_exercise_id": 2838,
    //                 "sets": 4,
    //                 "reps": 10,
    //                 "duration": null,
    //                 "rest": 90,
    //                 "created_at": "2025-03-29T21:08:45.000000Z",
    //                 "updated_at": "2025-03-29T21:08:45.000000Z"
    //             }
    //         }
    //     ]
    // },
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch custom workout: ${response.body}');
    }
  }

Future<List<dynamic>> fetchWorkout() async {
  final token = await TokenService.getToken();
  final response = await http.get(
    Uri.parse('$baseUrl/v2/workouts/custom-workouts'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    throw Exception('Failed to fetch custom workout: ${response.body}');
  }
}

  // store schedule workout
  Future<Map<String, dynamic>> storeScheduleWorkout(
    int workoutId,
    String scheduledAt,
  ) async {
    final token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/v2/workouts/scheduled-workouts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'workout_id': workoutId, 'scheduled_at': scheduledAt}),
    );
    // {
    //   "workout_id": 1,
    //   "scheduled_at": "2025-03-23 08:00:00"
    // }

    if (response.statusCode == 200|| response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store schedule workout: ${response.body}');
    }
  }

  //update schedule workout
  Future<Map<String, dynamic>> updateScheduleWorkout(
    int scheduleWorkoutId,
    String scheduledAt,
  ) async {
    final token = await TokenService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/v2/workouts/scheduled-workouts/$scheduleWorkoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'scheduled_at': scheduledAt}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update schedule workout: ${response.body}');
    }
  }

  //fetch schedule workout
  Future<Map<String, dynamic>> fetchScheduleWorkout(
    int scheduleWorkoutId,
  ) async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/scheduled-workouts/$scheduleWorkoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch schedule workout: ${response.body}');
    }
  }

  //store weekly workouts
  Future<Map<String, dynamic>> storeWeeklyWorkouts(
    String startDate,
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
        'start_date': startDate,
        'weeks': weeks,
        'days_pattern': daysPattern,
      }),
    );
    // {
    //   "start_date": "2025-03-30",
    //   "weeks": 4,
    //   "days_pattern": {
    //     "mon": 1,
    //     "tue": 2,
    //     "wed": null,
    //     "thu": 1,
    //     "fri": 2,
    //     "sat": null,
    //     "sun": null
    //   }
    // }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store weekly workouts: ${response.body}');
    }
  }

  // fetch weekly workouts
  Future<Map<String, dynamic>> fetchWeeklyWorkouts() async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/weekly-cycle-plans'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // output:
    // "weeks": {
    //     "13": {
    //         "mon": [
    //             {
    //                 "id": 1,
    //                 "user_id": 2,
    //                 "workout_id": 1,
    //                 "scheduled_at": "2025-03-24 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 1,
    //                     "user_id": 2,
    //                     "name": "chest Workout",
    //                     "description": "A custom workout routine focusing on chest and triceps.",
    //                     "created_at": "2025-03-29T21:08:45.000000Z",
    //                     "updated_at": "2025-03-29T21:08:45.000000Z"
    //                 }
    //             }
    //         ],
    //         "tue": [
    //             {
    //                 "id": 2,
    //                 "user_id": 2,
    //                 "workout_id": 2,
    //                 "scheduled_at": "2025-03-25 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 2,
    //                     "user_id": 2,
    //                     "name": "back Workout",
    //                     "description": "A custom workout routine focusing on back and biceps.",
    //                     "created_at": "2025-03-29T21:10:21.000000Z",
    //                     "updated_at": "2025-03-29T21:10:21.000000Z"
    //                 }
    //             }
    //         ],
    //         "wed": [],
    //         "thu": [
    //             {
    //                 "id": 3,
    //                 "user_id": 2,
    //                 "workout_id": 1,
    //                 "scheduled_at": "2025-03-27 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 1,
    //                     "user_id": 2,
    //                     "name": "chest Workout",
    //                     "description": "A custom workout routine focusing on chest and triceps.",
    //                     "created_at": "2025-03-29T21:08:45.000000Z",
    //                     "updated_at": "2025-03-29T21:08:45.000000Z"
    //                 }
    //             }
    //         ],
    //         "fri": [
    //             {
    //                 "id": 4,
    //                 "user_id": 2,
    //                 "workout_id": 2,
    //                 "scheduled_at": "2025-03-28 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 2,
    //                     "user_id": 2,
    //                     "name": "back Workout",
    //                     "description": "A custom workout routine focusing on back and biceps.",
    //                     "created_at": "2025-03-29T21:10:21.000000Z",
    //                     "updated_at": "2025-03-29T21:10:21.000000Z"
    //                 }
    //             }
    //         ],
    //         "sat": [],
    //         "sun": []
    //     },
    //     "14": {
    //         "mon": [
    //             {
    //                 "id": 17,
    //                 "user_id": 2,
    //                 "workout_id": 1,
    //                 "scheduled_at": "2025-03-31 00:00:00",
    //                 "created_at": "2025-03-29T22:03:55.000000Z",
    //                 "updated_at": "2025-03-29T22:03:55.000000Z",
    //                 "workout": {
    //                     "id": 1,
    //                     "user_id": 2,
    //                     "name": "chest Workout",
    //                     "description": "A custom workout routine focusing on chest and triceps.",
    //                     "created_at": "2025-03-29T21:08:45.000000Z",
    //                     "updated_at": "2025-03-29T21:08:45.000000Z"
    //                 }
    //             },
    //             {
    //                 "id": 5,
    //                 "user_id": 2,
    //                 "workout_id": 1,
    //                 "scheduled_at": "2025-03-31 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 1,
    //                     "user_id": 2,
    //                     "name": "chest Workout",
    //                     "description": "A custom workout routine focusing on chest and triceps.",
    //                     "created_at": "2025-03-29T21:08:45.000000Z",
    //                     "updated_at": "2025-03-29T21:08:45.000000Z"
    //                 }
    //             }
    //         ],
    //         "tue": [
    //             {
    //                 "id": 18,
    //                 "user_id": 2,
    //                 "workout_id": 2,
    //                 "scheduled_at": "2025-04-01 00:00:00",
    //                 "created_at": "2025-03-29T22:03:55.000000Z",
    //                 "updated_at": "2025-03-29T22:03:55.000000Z",
    //                 "workout": {
    //                     "id": 2,
    //                     "user_id": 2,
    //                     "name": "back Workout",
    //                     "description": "A custom workout routine focusing on back and biceps.",
    //                     "created_at": "2025-03-29T21:10:21.000000Z",
    //                     "updated_at": "2025-03-29T21:10:21.000000Z"
    //                 }
    //             },
    //             {
    //                 "id": 6,
    //                 "user_id": 2,
    //                 "workout_id": 2,
    //                 "scheduled_at": "2025-04-01 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 2,
    //                     "user_id": 2,
    //                     "name": "back Workout",
    //                     "description": "A custom workout routine focusing on back and biceps.",
    //                     "created_at": "2025-03-29T21:10:21.000000Z",
    //                     "updated_at": "2025-03-29T21:10:21.000000Z"
    //                 }
    //             }
    //         ],
    //         "wed": [],
    //         "thu": [
    //             {
    //                 "id": 7,
    //                 "user_id": 2,
    //                 "workout_id": 1,
    //                 "scheduled_at": "2025-04-03 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 1,
    //                     "user_id": 2,
    //                     "name": "chest Workout",
    //                     "description": "A custom workout routine focusing on chest and triceps.",
    //                     "created_at": "2025-03-29T21:08:45.000000Z",
    //                     "updated_at": "2025-03-29T21:08:45.000000Z"
    //                 }
    //             },
    //             {
    //                 "id": 19,
    //                 "user_id": 2,
    //                 "workout_id": 1,
    //                 "scheduled_at": "2025-04-03 00:00:00",
    //                 "created_at": "2025-03-29T22:03:55.000000Z",
    //                 "updated_at": "2025-03-29T22:03:55.000000Z",
    //                 "workout": {
    //                     "id": 1,
    //                     "user_id": 2,
    //                     "name": "chest Workout",
    //                     "description": "A custom workout routine focusing on chest and triceps.",
    //                     "created_at": "2025-03-29T21:08:45.000000Z",
    //                     "updated_at": "2025-03-29T21:08:45.000000Z"
    //                 }
    //             }
    //         ],
    //         "fri": [
    //             {
    //                 "id": 20,
    //                 "user_id": 2,
    //                 "workout_id": 2,
    //                 "scheduled_at": "2025-04-04 00:00:00",
    //                 "created_at": "2025-03-29T22:03:55.000000Z",
    //                 "updated_at": "2025-03-29T22:03:55.000000Z",
    //                 "workout": {
    //                     "id": 2,
    //                     "user_id": 2,
    //                     "name": "back Workout",
    //                     "description": "A custom workout routine focusing on back and biceps.",
    //                     "created_at": "2025-03-29T21:10:21.000000Z",
    //                     "updated_at": "2025-03-29T21:10:21.000000Z"
    //                 }
    //             },
    //             {
    //                 "id": 8,
    //                 "user_id": 2,
    //                 "workout_id": 2,
    //                 "scheduled_at": "2025-04-04 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 2,
    //                     "user_id": 2,
    //                     "name": "back Workout",
    //                     "description": "A custom workout routine focusing on back and biceps.",
    //                     "created_at": "2025-03-29T21:10:21.000000Z",
    //                     "updated_at": "2025-03-29T21:10:21.000000Z"
    //                 }
    //             }
    //         ],
    //         "sat": [],
    //         "sun": []
    //     },
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch weekly workouts: ${response.body}');
    }
  }
}
