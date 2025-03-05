// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class FoodDetailsScreen extends StatefulWidget {
  final Food food;
  const FoodDetailsScreen({super.key, required this.food});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isStoringMeal = false;
  String? _storeMealMessage;
  String? _selectedTime;
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _storeMeal() async {
    final name = widget.food.name.trim();
    final quantityText = _quantityController.text.trim();
    if (quantityText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a quantity")));
      return;
    }
    if (_selectedTime == null || _selectedTime!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a time")));
      return;
    }
    final double? quantity = double.tryParse(quantityText);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid quantity")),
      );
      return;
    }
    final mealTime = _selectedTime?.toLowerCase();
    final mealDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    setState(() {
      _isStoringMeal = true;
      _storeMealMessage = null;
    });

    try {
      await _apiService.storeMeal(name, quantity, mealTime, mealDate);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meal stored successfully!")),
      );
    } catch (error) {
      setState(() {
        _storeMealMessage = "Error: ${error.toString()}";
      });
    } finally {
      setState(() {
        _isStoringMeal = false;
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          widget.food.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nutrition Facts Card
              Container(
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nutrition Facts",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double spacing = constraints.maxWidth * 0.05;
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _nutritionItem(
                                    Icons.local_fire_department,
                                    "Calories",
                                    "${widget.food.calories}",
                                    Colors.orange.shade400,
                                  ),
                                  SizedBox(width: spacing),
                                  _nutritionItem(
                                    Icons.fitness_center,
                                    "Protein",
                                    "${widget.food.protein}g",
                                    Colors.green.shade400,
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _nutritionItem(
                                    Icons.grain,
                                    "Carbs",
                                    "${widget.food.carbs}g",
                                    Colors.blue.shade400,
                                  ),
                                  SizedBox(width: spacing),
                                  _nutritionItem(
                                    Icons.water_drop,
                                    "Fats",
                                    "${widget.food.fats}g",
                                    Colors.red.shade400,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Add to Meal Card
              Container(
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add to Meal Plan",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Date Picker
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat(
                                  'EEE, MMM d, yyyy',
                                ).format(_selectedDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: Colors.blue.shade700,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Meal Time Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedTime,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.access_time,
                            color: Colors.blue.shade700,
                          ),
                          hintText: "Select Meal Time",
                          hintStyle: TextStyle(color: Colors.blue.shade700),
                        ),
                        style: TextStyle(
                          color: Colors.black,
                        ), // Add this line to set the dropdown text color
                        dropdownColor:
                            Colors
                                .white, // Optional: set dropdown background color
                        items: const [
                          DropdownMenuItem(
                            value: "Breakfast",
                            child: Text("Breakfast"),
                          ),
                          DropdownMenuItem(
                            value: "Lunch",
                            child: Text("Lunch"),
                          ),
                          DropdownMenuItem(
                            value: "Dinner",
                            child: Text("Dinner"),
                          ),
                          DropdownMenuItem(
                            value: "Snack",
                            child: Text("Snack"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTime = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Quantity Input
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.scale,
                            color: Colors.blue.shade700,
                          ),
                          hintText: "Quantity (grams)",
                          hintStyle: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Add to Meal Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isStoringMeal ? null : _storeMeal,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child:
                              _isStoringMeal
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    "Add to Meal",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),

                      // Error/Success Message
                      if (_storeMealMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  _storeMealMessage!.startsWith("Error")
                                      ? Colors.red.shade100
                                      : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _storeMealMessage!,
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    _storeMealMessage!.startsWith("Error")
                                        ? Colors.red.shade800
                                        : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nutritionItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
