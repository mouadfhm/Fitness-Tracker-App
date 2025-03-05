import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/api_service.dart';

class FoodProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Food> _foods = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Food> get foods => _foods;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  FoodProvider() {
    fetchFoods();
  }

  Future<void> fetchFoods() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _apiService.getFoods();
      _foods = data.map((json) => Food.fromJson(json)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshFoods() async {
    await fetchFoods();
  }

  // Optionally, implement a method to add a food to the list.
  Future<void> addFood(Food newFood) async {
    // Add newFood to your backend via your API, then refresh the list.
    // For demonstration, we'll simply add it locally:
    _foods.add(newFood);
    notifyListeners();
  }
}
