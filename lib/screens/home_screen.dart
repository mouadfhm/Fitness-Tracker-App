// ignore_for_file: deprecated_member_use
import 'package:fitness_tracker_app/screens/workout/workout_calendar_screen.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'foods_screen.dart';
import 'login_screen.dart';
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
      const WorkoutCalendarScreen(),
      const FoodsScreen(),
      const ProfileScreen(),
    ];

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => routes[index]));
  }

  // Updated meal order to match the expanded options in FoodDetailsScreen
  final List<String> _mealOrder = [
    'breakfast',
    'morning snack',
    'lunch',
    'afternoon snack',
    'dinner',
    'evening snack',
    'snack',
    'pre-workout',
    'post-workout',
  ];

  Map<String, dynamic>? _dailyMacros;
  Map<String, dynamic>? _consumedMacros;
  Map<String, List<dynamic>> _groupedMeals = {};
  bool _isLoading = true;
  String? _errorMessage;
  // double? _caloriesBurned;

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
      // final today = DateTime.now().toString().substring(0, 10);

      // Fetch calories burned for today
      // await fetchBurnedCalories(today);

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

    // Get the color scheme to use appropriate theme colors
    final colorScheme = Theme.of(context).colorScheme;
    
    // Using dedicated surface and onSurface colors for better dark mode contrast
    final cardColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    
    // For dark theme, adapt colors to be more visible
    final adaptedColor = MediaQuery.of(context).platformBrightness == Brightness.dark 
        ? color.withOpacity(0.8) 
        : color;

    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.brightness == Brightness.dark
          ? colorScheme.onSurface.withOpacity(0.1)
          : Colors.transparent,
          width: 1,
        ),
      ),

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
                    Icon(icon, color: adaptedColor, size: 30),
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
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
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: adaptedColor.withOpacity(0.2),
                  color: adaptedColor,
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
    // Get the color scheme to use appropriate theme colors
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final cardColor = colorScheme.surface;
    
    // Using dedicated color for secondary text with better contrast in dark mode
    final secondaryTextColor = colorScheme.brightness == Brightness.dark
        ? colorScheme.onSurface.withOpacity(0.8)
        : colorScheme.onSurfaceVariant;

    if (_groupedMeals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_meals, size: 80, color: secondaryTextColor),
            const SizedBox(height: 16),
            Text(
              "No meals logged yet",
              style: TextStyle(fontSize: 18, color: secondaryTextColor),
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

        Map<String, Map<String, double>> groupedMacros = {};

        // Macro calculation logic remains the same
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

        // Get all meal times for this date including custom ones
        Set<String> availableMealTimes = groupedMacros.keys.toSet();
        
        // Sort meal times according to _mealOrder, with custom meal times at the end
        List<String> sortedMealTimes = [];
        
        // First add the predefined meal times that are present in the data
        for (var mealTime in _mealOrder) {
          if (availableMealTimes.contains(mealTime)) {
            sortedMealTimes.add(mealTime);
            availableMealTimes.remove(mealTime);
          }
        }
        
        // Then add any remaining custom meal times alphabetically
        sortedMealTimes.addAll(availableMealTimes.toList()..sort());

        return Card(
          elevation: 4,
          color: cardColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            // Add a subtle border for better visibility in dark mode
            side: BorderSide(
              color: colorScheme.brightness == Brightness.dark
                  ? colorScheme.onSurface.withOpacity(0.1)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Theme(
            // Use a local theme for the ExpansionTile colors
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              colorScheme: ColorScheme.fromSeed(
                seedColor: colorScheme.primary,
                brightness: colorScheme.brightness,
                primary: colorScheme.primary,
                onSurface: textColor,
              ),
            ),
            child: ExpansionTile(
              // initiallyExpanded: index == 0, // Expand today's meals by default
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                displayDate,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              children: sortedMealTimes.map((mealTime) {
                final macros = groupedMacros[mealTime]!;

                // Format meal time for display (capitalize first letter of each word)
                String displayMealTime = mealTime
                    .split(' ')
                    .map((word) => word.isEmpty 
                        ? '' 
                        : '${word[0].toUpperCase()}${word.substring(1)}')
                    .join(' ');

                return Container(
                  decoration: BoxDecoration(
                    // Add subtle highlight for meal items
                    color: colorScheme.brightness == Brightness.dark
                        ? colorScheme.onSurface.withOpacity(0.05)
                        : colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.onSurface.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      displayMealTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        // Organize nutrients with more readability
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: secondaryTextColor),
                            children: [
                              TextSpan(
                                text: "Calories: ",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: macros['calories']!.toStringAsFixed(1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            // Protein
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: secondaryTextColor),
                                  children: [
                                    TextSpan(
                                      text: "Protein: ",
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    TextSpan(
                                      text: "${macros['protein']!.toStringAsFixed(1)}g",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Fat
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: secondaryTextColor),
                                  children: [
                                    TextSpan(
                                      text: "Fat: ",
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    TextSpan(
                                      text: "${macros['fat']!.toStringAsFixed(1)}g",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Carbs
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: secondaryTextColor),
                                  children: [
                                    TextSpan(
                                      text: "Carbs: ",
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    TextSpan(
                                      text: "${macros['carbs']!.toStringAsFixed(1)}g",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right, 
                      color: colorScheme.primary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MealDetailScreen(
                            mealTime: mealTime,
                            foods: meals
                              .where(
                                (m) => m['meal_time'].toLowerCase() == mealTime,
                              )
                              .expand((m) => m['foods'])
                              .toList(),
                          ),
                        ),
                      ).then((_) {
                        // Refresh data when returning from MealDetailScreen
                        _fetchData();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the color scheme to use appropriate theme colors
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final brightness = colorScheme.brightness;

    // Define macro card colors based on theme brightness
    final caloriesColor = brightness == Brightness.dark ? Colors.red.shade300 : Colors.red;
    final proteinColor = brightness == Brightness.dark ? Colors.blue.shade300 : Colors.blue;
    final carbsColor = brightness == Brightness.dark ? Colors.green.shade300 : Colors.green;
    final fatColor = brightness == Brightness.dark ? Colors.orange.shade300 : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nutrition Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2, // Added some elevation for visual separation
        backgroundColor: colorScheme.surface, // Ensure app bar uses theme surface color
        foregroundColor: colorScheme.onSurface, // Ensure text uses theme text color
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Daily Goal Header with improved visibility
                      Container(
                        padding: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.onSurface.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.stacked_bar_chart,
                              color: textColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Daily Macro Goals',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Macro Progress Cards - Fixed GridView with themed colors
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildMacroCard(
                            label: 'Calories',
                            consumed:
                                (_consumedMacros?['totalCalories'] as num?)
                                    ?.toDouble() ??
                                0.0,
                            goal:
                                (_dailyMacros?['macros']['calories'] as num?)
                                    ?.toDouble() ??
                                0.0,
                            color: caloriesColor,
                            icon: Icons.local_fire_department,
                          ),
                          _buildMacroCard(
                            label: 'Protein',
                            consumed:
                                (_consumedMacros?['totalProtein'] as num?)
                                    ?.toDouble() ??
                                0.0,
                            goal:
                                (_dailyMacros?['macros']['protein'] as num?)
                                    ?.toDouble() ??
                                0.0,
                            color: proteinColor,
                            icon: Icons.fitness_center,
                          ),
                          _buildMacroCard(
                            label: 'Carbs',
                            consumed:
                                (_consumedMacros?['totalCarbs'] as num?)
                                    ?.toDouble() ??
                                0.0,
                            goal:
                                (_dailyMacros?['macros']['carbs'] as num?)
                                    ?.toDouble() ??
                                0.0,
                            color: carbsColor,
                            icon: Icons.grain,
                          ),
                          _buildMacroCard(
                            label: 'Fat',
                            consumed:
                                (_consumedMacros?['totalFat'] as num?)
                                    ?.toDouble() ??
                                0.0,
                            goal:
                                (_dailyMacros?['macros']['fats'] as num?)
                                    ?.toDouble() ??
                                0.0,
                            color: fatColor,
                            icon: Icons.water_drop,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Meals Section Header with improved visibility
                      Container(
                        padding: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.onSurface.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              color: textColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your Meals',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
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