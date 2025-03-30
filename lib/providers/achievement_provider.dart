import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AchievementsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _achievements = [];
  Map<int, dynamic> _userAchievements = {};
  bool _isLoading = false;
  String? _error;

  List<dynamic> get achievements => _achievements;
  Map<int, dynamic> get userAchievements => _userAchievements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isAchievementUnlocked(int achievementId) => _userAchievements.containsKey(achievementId);

  Future<void> loadAchievements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allAchievements = await _apiService.getAchievements();
      final userAchievements = await _apiService.getUserAchievements();

      _achievements = allAchievements;
      _userAchievements = {for (var achievement in userAchievements) achievement['achievement_id']: achievement};
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryLoadAchievements() async => loadAchievements();

  Color getColorForType(String type) {
    switch (type) {
      case 'meals':
        return Colors.green;
      case 'streak':
        return Colors.orange;
      case 'calories':
        return Colors.red;
      case 'workouts':
        return Colors.blue;
      case 'cardio':
        return Colors.purple;
      case 'progress':
        return Colors.teal;
      case 'weight':
        return Colors.indigo;
      case 'muscle':
        return Colors.brown;
      default:
        return Colors.amber;
    }
  }

  IconData getIconForType(String type) {
    switch (type) {
      case 'meals':
        return Icons.restaurant;
      case 'streak':
        return Icons.local_fire_department;
      case 'calories':
        return Icons.monitor_weight;
      case 'workouts':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'progress':
        return Icons.trending_up;
      case 'weight':
        return Icons.scale;
      case 'muscle':
        return Icons.sports_gymnastics;
      default:
        return Icons.emoji_events;
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString.substring(0, 10); // Fallback to simple substring
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String getTargetDescription(String type, int target) {
    switch (type) {
      case 'meals':
        return 'Log $target meal(s)';
      case 'streak':
        return 'Maintain a streak for $target days';
      case 'calories':
        return target > 1000
            ? 'Reach ${target / 1000}k calories'
            : 'Reach $target calories';
      case 'workouts':
        return 'Complete $target workout(s)';
      case 'cardio':
        return 'Complete $target cardio session(s)';
      case 'progress':
        return 'Log $target progress update(s)';
      case 'weight':
        return 'Lose $target kg';
      case 'muscle':
        return 'Gain $target kg of muscle';
      default:
        return 'Complete $target tasks';
    }
  }
}
