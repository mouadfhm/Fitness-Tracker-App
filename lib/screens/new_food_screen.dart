import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'foods_screen.dart';

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
      await _apiService.addFood(
        _nameController.text.trim(),
        double.parse(_caloriesController.text.trim()),
        double.parse(_proteinController.text.trim()),
        double.parse(_carbsController.text.trim()),
        double.parse(_fatsController.text.trim()),
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FoodsScreen()),
      );
      setState(() {
      });

      _formKey.currentState!.reset();
    } catch (error) {
      setState(() {
        _errorMessage = "Failed to add food. Please try again.";
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
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: '0 $unit',
          prefixIcon: Icon(icon, color: Colors.blue.shade600),
          suffixText: unit,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Add New Food', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Food Name Field
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Food Name',
                      hintText: 'Enter food name',
                      prefixIcon: Icon(Icons.food_bank, color: Colors.blue.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
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
                ),
                _buildNutritionField(
                  controller: _proteinController,
                  labelText: 'Protein',
                  unit: 'g',
                  icon: Icons.fitness_center,
                ),
                _buildNutritionField(
                  controller: _carbsController,
                  labelText: 'Carbohydrates',
                  unit: 'g',
                  icon: Icons.grain,
                ),
                _buildNutritionField(
                  controller: _fatsController,
                  labelText: 'Fats',
                  unit: 'g',
                  icon: Icons.water_drop,
                ),

                // Error Message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Add Food Button
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addFood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add Food',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
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