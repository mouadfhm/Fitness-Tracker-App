import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ExercisesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _allWorkouts = [];
  List<dynamic> get allWorkouts => _allWorkouts;

  List<dynamic> _filteredWorkouts = [];
  List<dynamic> get filteredWorkouts => _filteredWorkouts;

  List<String> _categories = [];
  List<String> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filtering parameters
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Future<void> fetchWorkouts() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final workouts = await _apiService.getExercices();

      // Extract unique categories from workouts
      final Set<String> categorySet = {'All'};
      for (var workout in workouts) {
        final category = workout['name']?.toString() ?? 'Other';
        if (category.isNotEmpty) {
          categorySet.add(category);
        }
      }

      _allWorkouts = workouts;
      _categories = categorySet.toList();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    List<dynamic> temp = [];
    // Filter by category first
    if (_selectedCategory == 'All') {
      temp = _allWorkouts;
    } else {
      temp = _allWorkouts.where((workout) {
        final name = workout['name']?.toString().toLowerCase() ?? '';
        return name == _selectedCategory.toLowerCase();
      }).toList();
    }
    // Then filter by search query if any
    if (_searchQuery.isNotEmpty) {
      temp = temp.where((workout) {
        final name = workout['name']?.toString().toLowerCase() ?? '';
        final description = workout['description']?.toString().toLowerCase() ?? '';
        return name.contains(_searchQuery.toLowerCase()) ||
            description.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    _filteredWorkouts = temp;
  }

  // Update category filter and re-filter workouts
  void updateCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Update search query and re-filter workouts
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }
}
