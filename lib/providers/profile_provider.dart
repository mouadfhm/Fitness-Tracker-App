// lib/providers/profile_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fitness_tracker_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? get profileData => _profileData;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  
  /// Fetch profile data from the API.
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final data = await _apiService.getProfile();
      
      // Get custom profile picture path from local storage if it exists
      final prefs = await SharedPreferences.getInstance();
      final customProfilePic = prefs.getString('profile_picture_path');
      
      if (customProfilePic != null && customProfilePic.isNotEmpty) {
        data['custom_profile_pic'] = customProfilePic;
      }
      
      _profileData = data;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Update profile picture.
  Future<void> updateProfilePicture(String imagePath) async {
    try {
      // Check if file exists
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Selected image does not exist');
      }
      
      // In a real app, you might upload this to a server
      // await _apiService.uploadProfilePicture(file);
      
      // Store the path in local storage for now
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_picture_path', imagePath);
      
      // Update the profile data
      if (_profileData != null) {
        _profileData!['custom_profile_pic'] = imagePath;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update profile picture: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Update profile information.
  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // In a real app, you would update the profile on the server
      final updatedProfile = await _apiService.updateProfile(updatedData);
      
      // Preserve custom profile picture if it exists
      if (_profileData != null && _profileData!.containsKey('custom_profile_pic')) {
        updatedProfile['custom_profile_pic'] = _profileData!['custom_profile_pic'];
      }
      
      _profileData = updatedProfile;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
/// Calculate BMI and fetch relevant health data.
Future<Map<String, dynamic>> fetchHealthStats() async {
  try {
    if (_profileData == null) {
      throw Exception('Profile data not available');
    }
    
    final double weight = _profileData!['weight'].toDouble();
    final double heightInCm = _profileData!['height'].toDouble();
    final double heightInMeters = heightInCm / 100;
    
    // Calculate BMI
    final double bmi = weight / (heightInMeters * heightInMeters);
    
    // Get today's date in format YYYY-MM-DD
    final today = DateTime.now().toString().substring(0, 10);
    
    // Fetch additional health data
    final double caloriesBurned = await _apiService.getCalories(today);
    final dailyMacros = await _apiService.getGoal();
    final consumedMacros = await _apiService.getMacros();
    
    // Calculate calorie deficit/surplus
    final double calorieGoal = dailyMacros['calories'] ?? 2000.0;
    final double consumedCalories = consumedMacros['calories'] ?? 0.0;
    final double calorieBalance = calorieGoal - consumedCalories + caloriesBurned;
    
    return {
      'bmi': bmi,
      'bmiCategory': _getBMICategory(bmi),
      'caloriesBurned': caloriesBurned,
      'dailyMacros': dailyMacros,
      'consumedMacros': consumedMacros,
      'calorieBalance': calorieBalance,
      // 'weightTrend': await _apiService.getWeightTrend(),
    };
  } catch (e) {
    _errorMessage = 'Failed to fetch health stats: ${e.toString()}';
    notifyListeners();
    rethrow;
  }
}

// Get BMI category based on the BMI value
String _getBMICategory(double bmi) {
  if (bmi < 18.5) return "Underweight";
  if (bmi < 25) return "Normal";
  if (bmi < 30) return "Overweight";
  return "Obese";
}  
  /// Reset profile data (for testing or logout).
  void resetProfile() {
    _profileData = null;
    notifyListeners();
  }
}