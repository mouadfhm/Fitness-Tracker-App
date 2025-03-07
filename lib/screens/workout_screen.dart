import 'package:fitness_tracker_app/screens/workout_details_screen.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _apiService = ApiService();
  String _searchQuery = '';
  List<dynamic> _allWorkouts = [];
  List<dynamic> _filteredWorkouts = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Track selected category filter
  String _selectedCategory = 'All';
  List<String> _categories = ['All']; // Will be populated dynamically

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  void _fetchWorkouts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final workouts = await _apiService.getExercices();

      // Extract unique categories from workouts
      final Set<String> categorySet = {'All'};
      for (var workout in workouts) {
        final category = workout['name']?.toString() ?? 'Other';
        if (category.isNotEmpty) {
          categorySet.add(category);
        }
      }

      setState(() {
        _allWorkouts = workouts;
        _categories = categorySet.toList();
        _applyFilters();
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      // First filter by category if needed
      var categoryFiltered =
          _selectedCategory == 'All'
              ? _allWorkouts
              : _allWorkouts.where((workout) {
                final category = workout['name']?.toString() ?? '';
                return category.toLowerCase() ==
                    _selectedCategory.toLowerCase();
              }).toList();

      // Then apply search query
      if (_searchQuery.isEmpty) {
        _filteredWorkouts = categoryFiltered;
      } else {
        _filteredWorkouts =
            categoryFiltered.where((workout) {
              final name = workout['name']?.toString().toLowerCase() ?? '';
              final description =
                  workout['description']?.toString().toLowerCase() ?? '';
              return name.contains(_searchQuery.toLowerCase()) ||
                  description.contains(_searchQuery.toLowerCase());
            }).toList();
      }
    });
  }

  void _filterWorkouts(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workouts',
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: _filterWorkouts,
                    decoration: InputDecoration(
                      hintText: 'Search workouts...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.blue.shade400,
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Category filters - now dynamic
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                            _applyFilters();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.blue.shade600
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Results count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isLoading
                          ? 'Loading workouts...'
                          : 'Found ${_filteredWorkouts.length} workouts',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _selectedCategory == 'All'
                          ? 'All Categories'
                          : _selectedCategory,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Workouts list
            _isLoading
                ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
                : _errorMessage != null
                ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading workouts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchWorkouts,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue.shade600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : _filteredWorkouts.isEmpty
                ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 56,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No workouts available'
                              : 'No workouts match your search',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty ||
                            _selectedCategory != 'All')
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _selectedCategory = 'All';
                                  _applyFilters();
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Clear filters'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
                : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final workout = _filteredWorkouts[index];
                      final description =
                          workout['description'] ?? 'No Description';
                      final category = workout['name'] ?? 'Other';
                      final difficulty =
                          workout['caloriesPerKg'] > 2
                              ? 'Hard'
                              : workout['caloriesPerKg'] > 1
                              ? 'Medium'
                              : 'Easy';

                      // Generate a color based on the category
                      final Color categoryColor = _getCategoryColor(category);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => WorkoutDetailsScreen(workout: workout),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top half with color based on category
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.15),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    _getCategoryIcon(category),
                                    size: 45,
                                    color: categoryColor,
                                  ),
                                ),
                              ),

                              // Bottom half with content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Use name and description together for better context
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              description,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Bottom row with metadata
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Category chip
                                          Flexible(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: categoryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                category,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: categoryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 4),

                                          // Difficulty indicator
                                          _buildDifficultyIndicator(difficulty),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: _filteredWorkouts.length),
                  ),
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // You could navigate to a "create custom workout" screen here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Create custom workout feature coming soon!"),
            ),
          );
        },
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper methods - now more dynamic with color mapping

  Color _getCategoryColor(String category) {
    // Create a more generic category color mapping
    final String cat = category.toLowerCase();

    if (cat.contains('strength') || cat.contains('power')) {
      return Colors.blue.shade700;
    } else if (cat.contains('cardio') || cat.contains('aerobic')) {
      return Colors.red.shade600;
    } else if (cat.contains('flex') || cat.contains('stretch')) {
      return Colors.purple.shade600;
    } else if (cat.contains('balance') || cat.contains('stability')) {
      return Colors.teal.shade600;
    } else if (cat.contains('endurance')) {
      return Colors.green.shade600;
    } else if (cat.contains('speed') || cat.contains('agility')) {
      return Colors.amber.shade600;
    } else {
      // Use hash code of category string to generate a consistent color
      final int hash = cat.hashCode.abs();
      return Color.fromARGB(
        255,
        (hash % 150) + 50, // Red component (50-200)
        ((hash ~/ 10) % 150) + 50, // Green component (50-200)
        ((hash ~/ 100) % 150) + 50, // Blue component (50-200)
      );
    }
  }

  IconData _getCategoryIcon(String category) {
    final String cat = category.toLowerCase();

    if (cat.contains('strength') || cat.contains('weight')) {
      return Icons.fitness_center;
    } else if (cat.contains('cardio') || cat.contains('run')) {
      return Icons.directions_run;
    } else if (cat.contains('flex') ||
        cat.contains('yoga') ||
        cat.contains('stretch')) {
      return Icons.accessibility_new;
    } else if (cat.contains('balance') || cat.contains('stability')) {
      return Icons.swap_horizontal_circle;
    } else if (cat.contains('endurance')) {
      return Icons.timer;
    } else if (cat.contains('sport')) {
      return Icons.sports;
    } else if (cat.contains('body') || cat.contains('weight')) {
      return Icons.person;
    } else {
      return Icons.fitness_center;
    }
  }

  Widget _buildDifficultyIndicator(String difficulty) {
    Color color;
    int level;

    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'beginner':
        color = Colors.green;
        level = 1;
        break;
      case 'medium':
      case 'intermediate':
        color = Colors.orange;
        level = 2;
        break;
      case 'hard':
      case 'advanced':
      case 'expert':
        color = Colors.red;
        level = 3;
        break;
      default:
        color = Colors.grey;
        level = 1;
    }

    return Row(
      children: List.generate(3, (index) {
        return Container(
          width: 5,
          height: index < 2 ? 8 : 12,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: index < level ? color : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
