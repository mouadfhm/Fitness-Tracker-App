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
}
