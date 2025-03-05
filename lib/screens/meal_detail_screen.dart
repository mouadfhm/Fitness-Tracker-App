// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  final String mealTime;
  final List<dynamic> foods;

  const MealDetailScreen({super.key, required this.mealTime, required this.foods});

  @override
  Widget build(BuildContext context) {
    // Calculate total nutritional values
    final totalCalories = foods.fold(0.0, (sum, food) {
      final quantity = (food['pivot']['quantity'] as num).toDouble();
      return sum + ((food['calories'] as num).toDouble() * quantity / 100);
    });

    final totalProtein = foods.fold(0.0, (sum, food) {
      final quantity = (food['pivot']['quantity'] as num).toDouble();
      return sum + ((food['protein'] as num).toDouble() * quantity / 100);
    });

    final totalFat = foods.fold(0.0, (sum, food) {
      final quantity = (food['pivot']['quantity'] as num).toDouble();
      return sum + ((food['fats'] as num).toDouble() * quantity / 100);
    });

    final totalCarbs = foods.fold(0.0, (sum, food) {
      final quantity = (food['pivot']['quantity'] as num).toDouble();
      return sum + ((food['carbs'] as num).toDouble() * quantity / 100);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "$mealTime Details",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Meal Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _nutritionSummaryItem(
                  Icons.local_fire_department,
                  "Calories",
                  totalCalories.toStringAsFixed(1),
                  Colors.red,
                ),
                _nutritionSummaryItem(
                  Icons.fitness_center,
                  "Protein",
                  "${totalProtein.toStringAsFixed(1)}g",
                  Colors.blue,
                ),
                _nutritionSummaryItem(
                  Icons.grain,
                  "Carbs",
                  "${totalCarbs.toStringAsFixed(1)}g",
                  Colors.green,
                ),
                _nutritionSummaryItem(
                  Icons.water_drop,
                  "Fat",
                  "${totalFat.toStringAsFixed(1)}g",
                  Colors.orange,
                ),
              ],
            ),
          ),

          // Food List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];
                final quantity = (food['pivot']['quantity'] as num).toDouble();
                final foodCalories = (food['calories'] as num).toDouble() * quantity / 100;
                final foodProtein = (food['protein'] as num).toDouble() * quantity / 100;
                final foodFat = (food['fats'] as num).toDouble() * quantity / 100;
                final foodCarbs = (food['carbs'] as num).toDouble() * quantity / 100;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      food['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _nutritionDetailRow(
                          Icons.local_fire_department,
                          "Calories",
                          "${foodCalories.toStringAsFixed(1)} kcal",
                          Colors.red,
                        ),
                        _nutritionDetailRow(
                          Icons.fitness_center,
                          "Protein",
                          "${foodProtein.toStringAsFixed(1)}g",
                          Colors.blue,
                        ),
                        _nutritionDetailRow(
                          Icons.grain,
                          "Carbs",
                          "${foodCarbs.toStringAsFixed(1)}g",
                          Colors.green,
                        ),
                        _nutritionDetailRow(
                          Icons.water_drop,
                          "Fat",
                          "${foodFat.toStringAsFixed(1)}g",
                          Colors.orange,
                        ),
                        _nutritionDetailRow(
                          Icons.scale,
                          "Quantity",
                          "${quantity.toStringAsFixed(1)}g",
                          Colors.purple,
                        ),
                      ],
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}