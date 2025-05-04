// ignore_for_file: deprecated_member_use

import 'package:fitness_tracker_app/services/api_service.dart';
import 'package:flutter/material.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealTime;
  final List<dynamic> foods;
  final Function(List<dynamic>)? onFoodsUpdated;

  const MealDetailScreen({
    super.key,
    required this.mealTime,
    required this.foods,
    this.onFoodsUpdated,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late List<dynamic> _foods;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _foods = List.from(widget.foods);
  }

  void _deleteFood(int index) async {
    final mealId = _foods[index]['pivot']['meal_id'];
    await _apiService.removeFoodFromMeal(mealId);

    setState(() {
      _foods.removeAt(index);
    });

    // Notify parent about the update
    if (widget.onFoodsUpdated != null) {
      widget.onFoodsUpdated!(_foods);
    }

    // Check if no foods left
    if (_foods.isEmpty) {
      // Return to previous screen if no foods left
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate total nutritional values
    final totalCalories = _foods.fold(0.0, (sum, food) {
      final quantity = (food['pivot']['quantity'] as num).toDouble();
      return sum + ((food['calories'] as num).toDouble() * quantity / 100);
    });

    final totalProtein = _foods.fold(0.0, (sum, food) {
      final quantity = (food['pivot']['quantity'] as num).toDouble();
      return sum + ((food['protein'] as num).toDouble() * quantity / 100);
    });

    final totalFat = _foods.fold(0.0, (sum, food) {
      final quantity = (food['pivot']['quantity'] as num).toDouble();
      return sum + ((food['fats'] as num).toDouble() * quantity / 100);
    });

    final totalCarbs = _foods.fold(0.0, (sum, food) {
      final quantity = (food['pivot']['quantity'] as num).toDouble();
      return sum + ((food['carbs'] as num).toDouble() * quantity / 100);
    });

    // Optimized colors that work well in both light and dark mode
    final redColor = isDark ? Colors.red.shade300 : Colors.red;
    final blueColor = isDark ? Colors.blue.shade300 : Colors.blue;
    final greenColor = isDark ? Colors.green.shade300 : Colors.green;
    final orangeColor = isDark ? Colors.orange.shade300 : Colors.orange;
    final purpleColor = isDark ? Colors.purple.shade300 : Colors.purple;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "${widget.mealTime} Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor:
            isDark
                ? theme.colorScheme.surface
                : const Color.fromARGB(0, 95, 95, 95),
        elevation: isDark ? 4 : 0,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      body: Column(
        children: [
          // Meal Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? theme.colorScheme.surface.withOpacity(0.8)
                      : theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      isDark
                          ? Colors.black.withOpacity(0.4)
                          : Colors.grey.withOpacity(0.3),
                  blurRadius: isDark ? 12 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border:
                  isDark
                      ? Border.all(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                        width: 1,
                      )
                      : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _nutritionSummaryItem(
                  Icons.local_fire_department,
                  "Calories",
                  totalCalories.toStringAsFixed(1),
                  redColor,
                ),
                _nutritionSummaryItem(
                  Icons.fitness_center,
                  "Protein",
                  "${totalProtein.toStringAsFixed(1)}g",
                  blueColor,
                ),
                _nutritionSummaryItem(
                  Icons.grain,
                  "Carbs",
                  "${totalCarbs.toStringAsFixed(1)}g",
                  greenColor,
                ),
                _nutritionSummaryItem(
                  Icons.water_drop,
                  "Fat",
                  "${totalFat.toStringAsFixed(1)}g",
                  orangeColor,
                ),
              ],
            ),
          ),

          // Food List
          Expanded(
            child:
                _foods.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.no_food,
                            size: 64,
                            color: theme.disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No foods in this meal",
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onBackground.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _foods.length,
                      itemBuilder: (context, index) {
                        final food = _foods[index];
                        final quantity =
                            (food['pivot']['quantity'] as num).toDouble();
                        final foodCalories =
                            (food['calories'] as num).toDouble() *
                            quantity /
                            100;
                        final foodProtein =
                            (food['protein'] as num).toDouble() *
                            quantity /
                            100;
                        final foodFat =
                            (food['fats'] as num).toDouble() * quantity / 100;
                        final foodCarbs =
                            (food['carbs'] as num).toDouble() * quantity / 100;

                        return Dismissible(
                          key: Key(food['id'].toString() + index.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade800,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: theme.dialogBackgroundColor,
                                  title: Text(
                                    "Remove Food",
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  content: Text(
                                    "Are you sure you want to remove ${food['name']} from this meal?",
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.grey.shade300
                                                  : Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: Text(
                                        "Remove",
                                        style: TextStyle(color: redColor),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            _deleteFood(index);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? theme.colorScheme.surface.withOpacity(
                                        0.8,
                                      )
                                      : theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      isDark
                                          ? Colors.black.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.2),
                                  blurRadius: isDark ? 8 : 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border:
                                  isDark
                                      ? Border.all(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.08),
                                        width: 1,
                                      )
                                      : null,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      food['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: redColor.withOpacity(0.8),
                                      size: 22,
                                    ),
                                    onPressed: () async {
                                      final confirmed = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor:
                                                theme.dialogBackgroundColor,
                                            title: Text(
                                              "Remove Food",
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                            ),
                                            content: Text(
                                              "Are you sure you want to remove ${food['name']} from this meal?",
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(false),
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    color:
                                                        isDark
                                                            ? Colors
                                                                .grey
                                                                .shade300
                                                            : Colors
                                                                .grey
                                                                .shade800,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(true),
                                                child: Text(
                                                  "Remove",
                                                  style: TextStyle(
                                                    color: redColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmed == true) {
                                        _deleteFood(index);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Divider(
                                    color: theme.dividerColor.withOpacity(
                                      isDark ? 0.2 : 0.1,
                                    ),
                                    thickness: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  _nutritionDetailRow(
                                    Icons.local_fire_department,
                                    "Calories",
                                    "${foodCalories.toStringAsFixed(1)} kcal",
                                    redColor,
                                  ),
                                  _nutritionDetailRow(
                                    Icons.fitness_center,
                                    "Protein",
                                    "${foodProtein.toStringAsFixed(1)}g",
                                    blueColor,
                                  ),
                                  _nutritionDetailRow(
                                    Icons.grain,
                                    "Carbs",
                                    "${foodCarbs.toStringAsFixed(1)}g",
                                    greenColor,
                                  ),
                                  _nutritionDetailRow(
                                    Icons.water_drop,
                                    "Fat",
                                    "${foodFat.toStringAsFixed(1)}g",
                                    orangeColor,
                                  ),
                                  _nutritionDetailRow(
                                    Icons.scale,
                                    "Quantity",
                                    "${quantity.toStringAsFixed(1)}g",
                                    purpleColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionSummaryItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.3 : 0.2),
            borderRadius: BorderRadius.circular(12),
            border:
                isDark
                    ? Border.all(color: color.withOpacity(0.5), width: 1)
                    : null,
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _nutritionDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              color: theme.colorScheme.onBackground.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
