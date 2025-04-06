import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../models/food.dart';
import '../providers/food_provider.dart';
import '../services/food_service.dart';
import 'food_details_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'workout/workout_calendar_screen.dart';
import 'new_food_screen.dart';
import 'widgets/bottom_nav_bar.dart';

enum SortBy {
  default_,
  calories,
  protein,
  carbs,
  fats
}

class FoodsScreen extends StatefulWidget {
  const FoodsScreen({super.key});

  @override
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen>
    with AutomaticKeepAliveClientMixin {
  final FoodService _foodService = FoodService();
  final TextEditingController _searchController = TextEditingController();
  SortBy _currentSortBy = SortBy.default_;
  bool _sortAscending = false;  // false = high to low (descending), true = low to high (ascending)

  Food? _scannedFood;
  final int _currentIndex = 2; // 0: Home, 1: Progress, 2: Foods, 3: Profile

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  /// Barcode scanning: attempts to scan and then fetch food info.
  Future<void> _scanBarcode() async {
    try {
      var scanResult = await BarcodeScanner.scan();
      String barcode = scanResult.rawContent;
      if (barcode.isEmpty) {
        _showSnackBar('No barcode scanned.');
        return;
      }
      setState(() {});
      var foodInfo = await _foodService.getFoodInfo(barcode);
      if (foodInfo != null) {
        final scannedFood = Food.fromJson(foodInfo);
        debugPrint('fooooooood: $scannedFood');
        // Optionally, add food to the provider (or your backend) here:
        await Provider.of<FoodProvider>(
          context,
          listen: false,
        ).addFood(scannedFood);
        
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
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

  /// Toggle sort option
  void _toggleSort(SortBy sortBy) {
    setState(() {
      // If same sort is selected, toggle direction
      if (_currentSortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        // For a new sort type, set to descending (high to low) by default
        _currentSortBy = sortBy;
        _sortAscending = false;
      }
    });
    Navigator.pop(context);
  }

  /// Show sort options dialog
  void _showSortOptions() {    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Sort Foods By',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.restore, 
                  color: _currentSortBy == SortBy.default_ 
                    ? Theme.of(context).colorScheme.primary
                    : null),
                title: Text('Default',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
                trailing: _currentSortBy == SortBy.default_ 
                  ? Icon(Icons.arrow_upward, color: Theme.of(context).colorScheme.primary) 
                  : null,
                selected: _currentSortBy == SortBy.default_,
                onTap: () => _toggleSort(SortBy.default_),
              ),
              ListTile(
                leading: Icon(Icons.local_fire_department, 
                  color: _currentSortBy == SortBy.calories 
                    ? Theme.of(context).colorScheme.error
                    : null),
                title: Text('Calories',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
                trailing: _currentSortBy == SortBy.calories 
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Theme.of(context).colorScheme.error)
                  : null,
                selected: _currentSortBy == SortBy.calories,
                onTap: () => _toggleSort(SortBy.calories),
              ),
              ListTile(
                leading: Icon(Icons.fitness_center,
                  color: _currentSortBy == SortBy.protein 
                    ? Colors.blue.shade700
                    : null),
                title: Text('Protein',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
                trailing: _currentSortBy == SortBy.protein 
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.blue.shade700)
                  : null,
                selected: _currentSortBy == SortBy.protein,
                onTap: () => _toggleSort(SortBy.protein),
              ),
              ListTile(
                leading: Icon(Icons.grain,
                  color: _currentSortBy == SortBy.carbs
                    ? Colors.green.shade700
                    : null),
                title: Text('Carbs',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
                trailing: _currentSortBy == SortBy.carbs 
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.green.shade700)
                  : null,
                selected: _currentSortBy == SortBy.carbs,
                onTap: () => _toggleSort(SortBy.carbs),
              ),
              ListTile(
                leading: Icon(Icons.opacity,
                  color: _currentSortBy == SortBy.fats
                    ? Colors.orange.shade700
                    : null),
                title: Text('Fat',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
                trailing: _currentSortBy == SortBy.fats 
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.orange.shade700)
                  : null,
                selected: _currentSortBy == SortBy.fats,
                onTap: () => _toggleSort(SortBy.fats),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Sort foods based on the current sort option
  List<Food> _sortFoods(List<Food> foods) {
    // Make a copy to avoid modifying the original list
    List<Food> sortedFoods = List.from(foods);
    
    switch (_currentSortBy) {
      case SortBy.default_:
        // Default sort - return the original list unsorted
        return foods;
      case SortBy.calories:
        sortedFoods.sort((a, b) => a.calories.compareTo(b.calories));
        break;
      case SortBy.protein:
        sortedFoods.sort((a, b) => a.protein.compareTo(b.protein));
        break;
      case SortBy.carbs:
        sortedFoods.sort((a, b) => a.carbs.compareTo(b.carbs));
        break;
      case SortBy.fats:
        sortedFoods.sort((a, b) => a.fats.compareTo(b.fats));
        break;
    }
    
    // If not ascending (high to low), reverse the list
    if (!_sortAscending) {
      return sortedFoods.reversed.toList();
    }
    
    return sortedFoods;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    // Get corresponding colors for nutrition based on theme
    final proteinColor = isDark ? Colors.blue.shade300 : Colors.blue.shade700;
    final carbsColor = isDark ? Colors.green.shade300 : Colors.green.shade700;
    final fatsColor = isDark ? Colors.orange.shade300 : Colors.orange.shade700;
    final caloriesColor = isDark ? Colors.red.shade300 : Colors.red.shade700;
    
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        // Filter foods based on search query.
        List<Food> filteredFoods =
            foodProvider.foods.where((food) {
              return food.name.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              );
            }).toList();
        
        // Apply sorting
        filteredFoods = _sortFoods(filteredFoods);

        // Get sort title to display
        String sortTitle = _getSortTitle();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Foods',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: _showSortOptions,
                tooltip: 'Sort foods',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                foodProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : foodProvider.errorMessage.isNotEmpty
                    ? Center(
                      child: Text(
                        foodProvider.errorMessage,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    )
                    : Column(
                      children: [
                        _buildSearchAndScanBar(),
                        const SizedBox(height: 10),
                        // Display current sort method
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Text(
                                'Sorting by: $sortTitle',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              if (_currentSortBy != SortBy.default_)
                                Icon(
                                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_scannedFood != null)
                          Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(_scannedFood!.name),
                              subtitle: Text(
                                'Calories: ${_scannedFood!.calories}',
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                color: colorScheme.primary),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => FoodDetailsScreen(
                                          food: _scannedFood!,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 10),
                        Expanded(
                          child:
                              filteredFoods.isEmpty
                                  ? Center(
                                    child: Text(
                                      'No foods found.',
                                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                  )
                                  : ListView.builder(
                                    key: const PageStorageKey<String>(
                                      'food_list',
                                    ),
                                    itemCount: filteredFoods.length,
                                    itemBuilder: (context, index) {
                                      final food = filteredFoods[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                          title: Text(
                                            food.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Calories: ${food.calories} kcal',
                                                style: TextStyle(
                                                  color: colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              // Always show relevant nutrition based on current sort
                                              _buildNutritionInfo(food, proteinColor, carbsColor, fatsColor, caloriesColor),
                                            ],
                                          ),
                                          leading: Icon(
                                            food.isFavorite == 1
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                food.isFavorite == 1
                                                    ? colorScheme.error
                                                    : colorScheme.onSurfaceVariant,
                                            size: 28,
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_forward_ios,
                                            color: colorScheme.primary,
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => FoodDetailsScreen(
                                                      food: food,
                                                    ),
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
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 4,
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

  // Build relevant nutrition info based on current sort
  Widget _buildNutritionInfo(Food food, Color proteinColor, Color carbsColor, Color fatsColor, Color caloriesColor) {
    switch (_currentSortBy) {
      case SortBy.protein:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: proteinColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Protein: ${food.protein}g',
            style: TextStyle(
              color: proteinColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case SortBy.carbs:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: carbsColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Carbs: ${food.carbs}g',
            style: TextStyle(
              color: carbsColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case SortBy.fats:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: fatsColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Fat: ${food.fats}g',
            style: TextStyle(
              color: fatsColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case SortBy.calories:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: caloriesColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Calories: ${food.calories} kcal',
            style: TextStyle(
              color: caloriesColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        // Default can show all macro info with pills
        return Wrap(
          spacing: 6,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: proteinColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'P: ${food.protein}g',
                style: TextStyle(color: proteinColor, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: carbsColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'C: ${food.carbs}g',
                style: TextStyle(color: carbsColor, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: fatsColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'F: ${food.fats}g',
                style: TextStyle(color: fatsColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
    }
  }

  // Helper method to get readable sort title
  String _getSortTitle() {
    switch (_currentSortBy) {
      case SortBy.default_:
        return 'Default';
      case SortBy.calories:
        return 'Calories';
      case SortBy.protein:
        return 'Protein';
      case SortBy.carbs:
        return 'Carbs';
      case SortBy.fats:
        return 'Fat';
    }
  }

  Widget _buildSearchAndScanBar() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Foods...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(color: colorScheme.onSurface),
              cursorColor: colorScheme.primary,
              onChanged: (query) => setState(() {}), // triggers rebuild to filter list
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _scanBarcode,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
            ),
            child: const Icon(Icons.qr_code, size: 28),
          ),
        ],
      ),
    );
  }
}