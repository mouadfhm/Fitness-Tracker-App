import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../models/food.dart';
import '../services/api_service.dart';
import '../services/food_service.dart';
import 'food_details_screen.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'new_food_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
class FoodsScreen extends StatefulWidget {
  const FoodsScreen({super.key});

  @override
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen> with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  final FoodService _foodService = FoodService();
  final TextEditingController _searchController = TextEditingController();

  List<Food> _foods = [];
  List<Food> _filteredFoods = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final int _currentIndex = 2;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFoods() async {
    try {
      final data = await _apiService.getFoods();
      if (mounted) {
        setState(() {
          _foods = data.map((json) => Food.fromJson(json)).toList();
          _filteredFoods = _foods;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterFoods(String query) {
    final filtered = _foods
        .where((food) => food.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    
    setState(() {
      _filteredFoods = filtered;
    });
  }

  Future<void> loadFoodData() async {
    String jsonString = await rootBundle.loadString('assets/foods.json');
    _foods = json.decode(jsonString);
  }
  Future<void> _scanBarcode() async {
    try {
      var scanResult = await BarcodeScanner.scan();
      String barcode = scanResult.rawContent;
      
      if (barcode.isEmpty) {
        _showSnackBar('No barcode scanned.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      var foodInfo = await _foodService.getFoodInfo(barcode);
      
      if (foodInfo != null) {
        final scannedFood = Food.fromJson(foodInfo);
        
        try {
          await _apiService.addFood(
            scannedFood.name.trim(),
            scannedFood.calories,
            scannedFood.protein,
            scannedFood.carbs,
            scannedFood.fats,
          );
        } catch (e) {
          _showSnackBar('Error adding food: $e');
        }

        // Navigate to food details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailsScreen(food: scannedFood),
          ),
        );
      } else {
        _showSnackBar('Food not found for barcode: $barcode');
      }
    } catch (e) {
      _showSnackBar('Error scanning barcode: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _onNavBarTap(int index) {
    final routes = [
      const HomeScreen(),
      const ProgressScreen(),
      const FoodsScreen(),
      const ProfileScreen(),
    ];

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => routes[index]),
    );
  }

  Future<void> _goToNewFood() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewFoodScreen()),
    );
    _fetchFoods();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Foods',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndScanBar(),
          Expanded(child: _buildFoodList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToNewFood,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildSearchAndScanBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Foods...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: _filterFoods,
            ),
          ),
          const SizedBox(width: 12),
            ElevatedButton(
            onPressed: _scanBarcode,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.black), // Added black border
              ),
              padding: const EdgeInsets.all(8),
            ),
            child: const Icon(Icons.qr_code, size: 28),
            ),
        ],
      ),
    );
  }

  Widget _buildFoodList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_filteredFoods.isEmpty) {
      return const Center(
        child: Text(
          'No foods found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey<String>('food_list'),
      itemCount: _filteredFoods.length,
      itemBuilder: (context, index) {
        final food = _filteredFoods[index];
        return _buildFoodListItem(food);
      },
    );
  }

  Widget _buildFoodListItem(Food food) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          food.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Calories: ${food.calories} kcal',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.black87,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodDetailsScreen(food: food),
            ),
          );
        },
      ),
    );
  }
}