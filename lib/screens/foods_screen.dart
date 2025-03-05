import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../models/food.dart';
import '../providers/food_provider.dart';
import '../services/food_service.dart';
import 'food_details_screen.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'new_food_screen.dart';
import 'widgets/bottom_nav_bar.dart';

class FoodsScreen extends StatefulWidget {
  const FoodsScreen({super.key});

  @override
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen>
    with AutomaticKeepAliveClientMixin {
  final FoodService _foodService = FoodService();
  final TextEditingController _searchController = TextEditingController();

  Food? _scannedFood;
  final int _currentIndex = 2; // 0: Home, 1: Progress, 2: Foods, 3: Profile

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Barcode scanning: attempts to scan and then fetch food info.
  Future<void> _scanBarcode() async {
    try {
      var scanResult = await BarcodeScanner.scan();
      String barcode = scanResult.rawContent;
      if (barcode.isEmpty) {
        _showSnackBar('No barcode scanned.');
        return;
      }
      setState(() {
      });
      var foodInfo = await _foodService.getFoodInfo(barcode);
      if (foodInfo != null) {
        final scannedFood = Food.fromJson(foodInfo);
        // Optionally, add food to the provider (or your backend) here:
        await Provider.of<FoodProvider>(context, listen: false)
            .addFood(scannedFood);
        // Navigate to FoodDetailsScreen directly.
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

  /// Bottom Navigation tap handler.
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

  /// Navigates to NewFoodScreen. On return, refresh the provider.
  Future<void> _goToNewFood(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewFoodScreen()),
    );
    Provider.of<FoodProvider>(context, listen: false).refreshFoods();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        // Filter foods based on search query.
        List<Food> filteredFoods = foodProvider.foods.where((food) {
          return food.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Foods',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: foodProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : foodProvider.errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          foodProvider.errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : Column(
                        children: [
                          _buildSearchAndScanBar(),
                          const SizedBox(height: 10),
                          if (_scannedFood != null)
                            Card(
                              child: ListTile(
                                title: Text(_scannedFood!.name),
                                subtitle: Text(
                                    'Calories: ${_scannedFood!.calories}'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          FoodDetailsScreen(food: _scannedFood!),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            const Text('No food scanned'),
                          const SizedBox(height: 10),
                          Expanded(
                            child: filteredFoods.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No foods found.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    key: const PageStorageKey<String>('food_list'),
                                    itemCount: filteredFoods.length,
                                    itemBuilder: (context, index) {
                                      final food = filteredFoods[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8),
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
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.black87,
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    FoodDetailsScreen(food: food),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _goToNewFood(context),
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onNavBarTap,
          ),
        );
      },
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (query) => setState(() {}), // triggers rebuild to filter list
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _scanBarcode,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.black),
              ),
              padding: const EdgeInsets.all(10),
            ),
            child: const Icon(Icons.qr_code, size: 28),
          ),
        ],
      ),
    );
  }
}
