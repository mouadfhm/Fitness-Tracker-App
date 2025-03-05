import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../models/food.dart';
import '../services/food_service.dart';
import 'food_details_screen.dart';

class FoodScanScreen extends StatefulWidget {
  const FoodScanScreen({super.key});

  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen> {
  final FoodService _foodService = FoodService();
  Food? _scannedFood;
  bool _isLoading = false;
  String _errorMessage = '';

  /// Initiates barcode scanning, fetches food info and updates UI.
  Future<void> _scanBarcode() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
      _scannedFood = null;
    });
    try {
      // Trigger the barcode scan
      var scanResult = await BarcodeScanner.scan();
      String barcode = scanResult.rawContent;
      if (barcode.isEmpty) {
        setState(() {
          _errorMessage = 'No barcode scanned.';
          _isLoading = false;
        });
        return;
      }
      // Fetch food info using the scanned barcode
      var foodInfo = await _foodService.getFoodInfo(barcode);
      if (foodInfo != null) {
        setState(() {
          _scannedFood = Food.fromJson(foodInfo);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Food not found for barcode: $barcode';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error scanning barcode: $e';
        _isLoading = false;
      });
    }
  }

  /// Navigate to FoodDetailsScreen, where users can add the food into a meal.
  void _goToFoodDetails() {
    if (_scannedFood != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodDetailsScreen(food: _scannedFood!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Food Barcode")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _scanBarcode,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Scan Barcode"),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (_scannedFood != null)
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _scannedFood!.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text("Calories: ${_scannedFood!.calories} kcal"),
                            Text("Protein: ${_scannedFood!.protein} g"),
                            Text("Carbs: ${_scannedFood!.carbs} g"),
                            Text("Fats: ${_scannedFood!.fats} g"),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _goToFoodDetails,
                              child: const Text("Add to Meal"),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
