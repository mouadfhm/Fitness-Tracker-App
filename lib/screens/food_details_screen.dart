// ignore_for_file: deprecated_member_use

import 'package:fitness_tracker_app/providers/food_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final TextEditingController _customMealTimeController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isStoringMeal = false;
  bool _isTogglingFavorite = false;
  String? _storeMealMessage;
  String? _selectedTime;
  bool _isCustomMealTime = false;
  DateTime _selectedDate = DateTime.now();
  bool _isFavorite = false;

  // Predefined meal time options
  final List<String> _predefinedMealTimes = [
    "Breakfast",
    "Lunch",
    "Dinner",
    "Snack",
    "Morning Snack",
    "Afternoon Snack",
    "Evening Snack",
    "Pre-workout",
    "Post-workout",
    "Custom"
  ];

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.food.isFavorite == 1;
  }

  Future<void> _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.brightness == Brightness.dark
                ? ColorScheme.dark(
                    primary: Colors.blue.shade400,
                    onPrimary: Colors.black,
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
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
    
    String? mealTime;
    if (_isCustomMealTime) {
      mealTime = _customMealTimeController.text.trim();
      if (mealTime.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please enter a meal time")));
        return;
      }
    } else {
      mealTime = _selectedTime;
      if (mealTime == null || mealTime.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please select a meal time")));
        return;
      }
    }
    
    final double? quantity = double.tryParse(quantityText);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid quantity")),
      );
      return;
    }
    
    final mealTimeValue = mealTime.toLowerCase();
    final mealDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    setState(() {
      _isStoringMeal = true;
      _storeMealMessage = null;
    });

    try {
      await _apiService.storeMeal(name, quantity, mealTimeValue, mealDate);
      setState(() {
        _storeMealMessage = "Meal stored successfully!";
      });
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

  Future<void> toggleFavoriteFood() async {
    if (_isTogglingFavorite) return;

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      if (_isFavorite) {
        await _apiService.removeFavoriteFood(widget.food.id);
        _showFeedback("Removed from favorites");
      } else {
        await _apiService.addFavoriteFood(widget.food.id);
        _showFeedback("Added to favorites");
      }
      Provider.of<FoodProvider>(context, listen: false).refreshFoods();
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (error) {
      _showFeedback(
        "Error updating favorites: ${error.toString()}",
        isError: true,
      );
    } finally {
      setState(() {
        _isTogglingFavorite = false;
      });
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Colors.red.shade700 
            : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        action: isError
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: toggleFavoriteFood,
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customMealTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;
    final Color cardColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final Color inputBgColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;
    final Color scaffoldBgColor = isDarkMode ? Colors.black : Colors.grey.shade100;
    
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          widget.food.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _isTogglingFavorite
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(_isFavorite),
                      color: Colors.red,
                    ),
            ),
            onPressed: _isTogglingFavorite ? null : toggleFavoriteFood,
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
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
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode 
                          ? Colors.black54 
                          : Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isDarkMode 
                      ? Border.all(color: Colors.grey.shade800, width: 1) 
                      : null,
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
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double spacing = constraints.maxWidth * 0.05;
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _nutritionItem(
                                    Icons.local_fire_department,
                                    "Calories",
                                    "${widget.food.calories}",
                                    Colors.red.shade400,
                                    isDarkMode,
                                    subTextColor,
                                  ),
                                  SizedBox(width: spacing),
                                  _nutritionItem(
                                    Icons.fitness_center,
                                    "Protein",
                                    "${widget.food.protein}g",
                                    Colors.blue.shade400,
                                    isDarkMode,
                                    subTextColor,
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _nutritionItem(
                                    Icons.grain,
                                    "Carbs",
                                    "${widget.food.carbs}g",
                                    Colors.green.shade400,
                                    isDarkMode,
                                    subTextColor,
                                  ),
                                  SizedBox(width: spacing),
                                  _nutritionItem(
                                    Icons.water_drop,
                                    "Fats",
                                    "${widget.food.fats}g",
                                    Colors.orange.shade400,
                                    isDarkMode,
                                    subTextColor,
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
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode 
                          ? Colors.black54 
                          : Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isDarkMode 
                      ? Border.all(color: Colors.grey.shade800, width: 1) 
                      : null,
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
                          color: textColor,
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
                            color: inputBgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: isDarkMode 
                                ? Border.all(color: Colors.grey.shade700) 
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: subTextColor,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: subTextColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Meal Time Selection
                      if (!_isCustomMealTime)
                        DropdownButtonFormField<String>(
                          value: _selectedTime,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: inputBgColor,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: isDarkMode
                                  ? BorderSide(color: Colors.grey.shade700)
                                  : BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: isDarkMode
                                  ? BorderSide(color: Colors.grey.shade700)
                                  : BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.access_time,
                              color: subTextColor,
                            ),
                            hintText: "Select Meal Time",
                            hintStyle: TextStyle(color: subTextColor),
                          ),
                          style: TextStyle(color: textColor),
                          dropdownColor: cardColor,
                          items: _predefinedMealTimes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTime = value;
                              _isCustomMealTime = value == "Custom";
                            });
                          },
                        ),

                      // Custom Meal Time Input
                      if (_isCustomMealTime)
                        Column(
                          children: [
                            TextField(
                              controller: _customMealTimeController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: inputBgColor,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: isDarkMode
                                      ? BorderSide(color: Colors.grey.shade700)
                                      : BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: isDarkMode
                                      ? BorderSide(color: Colors.grey.shade700)
                                      : BorderSide.none,
                                ),
                                prefixIcon: Icon(
                                  Icons.access_time,
                                  color: subTextColor,
                                ),
                                hintText: "Enter Custom Meal Time",
                                hintStyle: TextStyle(color: subTextColor),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.close, color: subTextColor),
                                  onPressed: () {
                                    setState(() {
                                      _isCustomMealTime = false;
                                      _selectedTime = null;
                                      _customMealTimeController.clear();
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Examples: Mid-morning, Late-night, Second Breakfast, etc.",
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Quantity Input
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBgColor,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: isDarkMode
                                ? BorderSide(color: Colors.grey.shade700)
                                : BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: isDarkMode
                                ? BorderSide(color: Colors.grey.shade700)
                                : BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.scale,
                            color: subTextColor,
                          ),
                          hintText: "Quantity (grams)",
                          hintStyle: TextStyle(color: subTextColor),
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
                            foregroundColor: Colors.white,
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: _isStoringMeal
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
                              color: _storeMealMessage!.startsWith("Error")
                                  ? (isDarkMode ? Colors.red.shade900 : Colors.red.shade100)
                                  : (isDarkMode ? Colors.green.shade900 : Colors.green.shade100),
                              borderRadius: BorderRadius.circular(12),
                              border: isDarkMode
                                  ? Border.all(
                                      color: _storeMealMessage!.startsWith("Error")
                                          ? Colors.red.shade800
                                          : Colors.green.shade800,
                                    )
                                  : null,
                            ),
                            child: Text(
                              _storeMealMessage!,
                              style: TextStyle(
                                fontSize: 16,
                                color: _storeMealMessage!.startsWith("Error")
                                    ? (isDarkMode ? Colors.red.shade200 : Colors.red.shade800)
                                    : (isDarkMode ? Colors.green.shade200 : Colors.green.shade800),
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
    bool isDarkMode,
    Color labelColor,
  ) {
    // Adjust color for better visibility in dark mode
    Color itemColor = isDarkMode ? color.withOpacity(0.8) : color;
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: itemColor.withOpacity(isDarkMode ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: isDarkMode 
              ? Border.all(color: itemColor.withOpacity(0.3)) 
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: itemColor.withOpacity(isDarkMode ? 0.3 : 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: itemColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: labelColor),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: itemColor,
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