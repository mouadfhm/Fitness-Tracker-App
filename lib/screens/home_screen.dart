// ignore_for_file: deprecated_member_use
import 'package:fitness_tracker_app/screens/workout_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'foods_screen.dart';
import 'meal_detail_screen.dart';
import '../services/api_service.dart';
import 'widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final int _currentIndex = 0;

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return;

    final routes = [
      const HomeScreen(),
      const WorkoutScreen(),
      const FoodsScreen(),
      const ProfileScreen(),
    ];

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => routes[index]));
  }

  Map<String, dynamic>? _dailyMacros;
  Map<String, dynamic>? _consumedMacros;
  Map<String, List<dynamic>> _groupedMeals = {};
  bool _isLoading = true;
  String? _errorMessage;
  double? _caloriesBurned;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _logout() async {
    await _apiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _fetchData() async {
    try {
      final dailyMacros = await _apiService.getGoal();
      final consumedMacros = await _apiService.getMacros();
      final mealsData = await _apiService.getMeals();

      Map<String, List<dynamic>> groupedMeals = {};
      for (var meal in mealsData) {
        final date = meal['date'].substring(0, 10);
        groupedMeals.putIfAbsent(date, () => []).add(meal);
      }

      // Get today's date in format YYYY-MM-DD
      final today = DateTime.now().toString().substring(0, 10);

      // Fetch calories burned for today
      await fetchBurnedCalories(today);

      // Check if the widget is still mounted before calling setState
      if (!mounted) return;
      setState(() {
        _dailyMacros = dailyMacros;
        _consumedMacros = consumedMacros;
        _groupedMeals = groupedMeals;
        _isLoading = false;
      });
    } catch (error) {
      // Check if the widget is still mounted before calling setState
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> fetchBurnedCalories(String date) async {
    try {
      final double caloriesBurned = await _apiService.getCalories(date);
      if (!mounted) return;
      setState(() {
        _caloriesBurned = caloriesBurned;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  Widget _buildCaloriesBurnedCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.red, size: 30),
                const SizedBox(width: 12),
                Text(
                  'Calories Burned Today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _caloriesBurned != null
                  ? '${_caloriesBurned!.toStringAsFixed(1)} kcal'
                  : 'No data available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCard({
    required String label,
    double? consumed,
    double? goal,
    required Color color,
    required IconData icon,
  }) {
    double progress =
        (consumed != null && goal != null && goal > 0)
            ? (consumed / goal).clamp(0.0, 1.0)
            : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: color, size: 30),
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${consumed?.toStringAsFixed(1) ?? 0} / ${goal?.toStringAsFixed(1) ?? 0}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withOpacity(0.2),
                  color: color,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMealsSection() {
    if (_groupedMeals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_meals, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No meals logged yet",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    List<String> dates =
        _groupedMeals.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        List<Map<String, dynamic>> meals = List<Map<String, dynamic>>.from(
          _groupedMeals[date]!,
        );

        const List<String> mealOrder = [
          'breakfast',
          'lunch',
          'dinner',
          'snack',
        ];

        Map<String, Map<String, double>> groupedMacros = {};

        // Macro calculation logic remains the same as in previous version
        for (var meal in meals) {
          String mealTime = meal['meal_time']?.toLowerCase() ?? 'unknown';

          if (!groupedMacros.containsKey(mealTime)) {
            groupedMacros[mealTime] = {
              'calories': 0.0,
              'protein': 0.0,
              'fat': 0.0,
              'carbs': 0.0,
            };
          }

          if (meal['foods'] != null) {
            for (var food in meal['foods']) {
              final quantity = (food['pivot']['quantity'] as num).toDouble();
              groupedMacros[mealTime]!['calories'] =
                  (groupedMacros[mealTime]!['calories'] ?? 0) +
                  ((food['calories'] as num).toDouble() * quantity / 100);
              groupedMacros[mealTime]!['protein'] =
                  (groupedMacros[mealTime]!['protein'] ?? 0) +
                  ((food['protein'] as num).toDouble() * quantity / 100);
              groupedMacros[mealTime]!['fat'] =
                  (groupedMacros[mealTime]!['fat'] ?? 0) +
                  ((food['fats'] as num).toDouble() * quantity / 100);
              groupedMacros[mealTime]!['carbs'] =
                  (groupedMacros[mealTime]!['carbs'] ?? 0) +
                  ((food['carbs'] as num).toDouble() * quantity / 100);
            }
          }
        }

        // Date formatting
        String displayDate =
            date == DateTime.now().toString().substring(0, 10)
                ? "Today"
                : date ==
                    DateTime.now()
                        .subtract(const Duration(days: 1))
                        .toString()
                        .substring(0, 10)
                ? "Yesterday"
                : DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(date));

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              displayDate,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            children:
                mealOrder
                    .where((mealTime) => groupedMacros.containsKey(mealTime))
                    .map((mealTime) {
                      final macros = groupedMacros[mealTime]!;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          mealTime.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        subtitle: Text(
                          "Calories: ${macros['calories']!.toStringAsFixed(1)}  "
                          "Protein: ${macros['protein']!.toStringAsFixed(1)}g  "
                          "Fat: ${macros['fat']!.toStringAsFixed(1)}g  "
                          "Carbs: ${macros['carbs']!.toStringAsFixed(1)}g",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => MealDetailScreen(
                                    mealTime: mealTime,
                                    foods:
                                        meals
                                            .where(
                                              (m) =>
                                                  m['meal_time']
                                                      .toLowerCase() ==
                                                  mealTime,
                                            )
                                            .expand((m) => m['foods'])
                                            .toList(),
                                  ),
                            ),
                          );
                        },
                      );
                    })
                    .toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nutrition Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Daily Goal Header
                        Text(
                          'Daily Macro Goals',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Macro Progress Cards
                        GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          children: [
                            Expanded(
                              child: _buildMacroCard(
                                label: 'Calories',
                                consumed:
                                    (_consumedMacros?['totalCalories'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                                goal:
                                    (_dailyMacros?['macros']['calories']
                                            as num?)
                                        ?.toDouble() ??
                                    0.0,
                                color: Colors.red,
                                icon: Icons.local_fire_department,
                              ),
                            ),
                            Expanded(
                              child: _buildMacroCard(
                                label: 'Protein',
                                consumed:
                                    (_consumedMacros?['totalProtein'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                                goal:
                                    (_dailyMacros?['macros']['protein'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                                color: Colors.blue,
                                icon: Icons.fitness_center,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMacroCard(
                                label: 'Carbs',
                                consumed:
                                    (_consumedMacros?['totalCarbs'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                                goal:
                                    (_dailyMacros?['macros']['carbs'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                                color: Colors.green,
                                icon: Icons.grain,
                              ),
                            ),
                            Expanded(
                              child: _buildMacroCard(
                                label: 'Fat',
                                consumed:
                                    (_consumedMacros?['totalFat'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                                goal:
                                    (_dailyMacros?['macros']['fats'] as num?)
                                        ?.toDouble() ??
                                    0.0,
                                color: Colors.orange,
                                icon: Icons.water_drop,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        // Calories Burned Section
                        _buildCaloriesBurnedCard(),
                        const SizedBox(height: 24),

                        // Meals Section Header
                        Text(
                          'Your Meals',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Meals Section
                        _buildMealsSection(),
                      ],
                    ),
                  ),
                ),
              ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
