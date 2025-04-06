import 'package:fitness_tracker_app/models/food.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'food_details_screen.dart';

class NewFoodScreen extends StatefulWidget {
  const NewFoodScreen({super.key});

  @override
  State<NewFoodScreen> createState() => _NewFoodScreenState();
}

class _NewFoodScreenState extends State<NewFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatsController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  final _apiService = ApiService();

  void _addFood() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var food = await _apiService.addFood(
        _nameController.text.trim(),
        double.parse(_caloriesController.text.trim()),
        double.parse(_proteinController.text.trim()),
        double.parse(_carbsController.text.trim()),
        double.parse(_fatsController.text.trim()),
      );
      food = food['food'];
      final foodModel = Food.fromJson(food);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodDetailsScreen(food: foodModel),
        ),
      );

      _formKey.currentState!.reset();
    } catch (error) {
      setState(() {
        _errorMessage = "Failed to add food. Please try again.";
        debugPrint('error: $error');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildNutritionField({
    required TextEditingController controller,
    required String labelText,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
          hintText: '0 $unit',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          ),
          prefixIcon: Icon(icon, color: color),
          suffixText: unit,
          suffixStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          final number = double.tryParse(value);
          if (number == null || number < 0) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Add New Food',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Food Name Field
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.grey.shade200,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Food Name',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                        hintText: 'Enter food name',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                        ),
                        prefixIcon: Icon(
                          Icons.restaurant,
                          color: primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter food name';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Nutrition Fields
                  _buildNutritionField(
                    controller: _caloriesController,
                    labelText: 'Calories',
                    unit: 'kcal',
                    icon: Icons.local_fire_department,
                    color: Colors.red.shade400,
                  ),
                  _buildNutritionField(
                    controller: _proteinController,
                    labelText: 'Protein',
                    unit: 'g',
                    icon: Icons.fitness_center,
                    color: Colors.blue.shade400,
                  ),
                  _buildNutritionField(
                    controller: _carbsController,
                    labelText: 'Carbohydrates',
                    unit: 'g',
                    icon: Icons.grain,
                    color: Colors.green.shade400,
                  ),
                  _buildNutritionField(
                    controller: _fatsController,
                    labelText: 'Fats',
                    unit: 'g',
                    icon: Icons.water_drop,
                    color: Colors.orange.shade400,
                  ),

                  // Error Message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // Add Food Button
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addFood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: isDark 
                          ? Colors.grey.shade700 
                          : Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isDark ? 4 : 3,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: isDark ? Colors.grey.shade300 : Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Add Food',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }
}