// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import 'workout_details_screen.dart';
import 'home_screen.dart';
import 'foods_screen.dart';
import 'profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    // Ensure workouts are fetched after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExercisesProvider>(context, listen: false).refreshWorkouts();
    });
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return;

    final routes = [
      const HomeScreen(),
      const WorkoutScreen(),
      const FoodsScreen(),
      const ProfileScreen(),
    ];

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => routes[index]));
  }

  // Helper methods for dynamic styling

  Color _getCategoryColor(String category) {
    final String cat = category.toLowerCase();

    // Strength and weight training
    if (cat.contains('strength') ||
        cat.contains('weight') ||
        cat.contains('gym')) {
      return Colors.blue.shade700;
    }
    // Cardio activities
    else if (cat.contains('cardio') ||
        cat.contains('run') ||
        cat.contains('jog')) {
      return Colors.red.shade600;
    }
    // Flexibility activities
    else if (cat.contains('flex') ||
        cat.contains('stretch') ||
        cat.contains('yoga')) {
      return Colors.purple.shade600;
    }
    // Ball sports
    else if (cat.contains('basketball') ||
        cat.contains('football') ||
        cat.contains('soccer') ||
        cat.contains('tennis') ||
        cat.contains('volleyball') ||
        cat.contains('baseball')) {
      return Colors.orange.shade600;
    }
    // Cycling activities
    else if (cat.contains('cycling') ||
        cat.contains('bike') ||
        cat.contains('biking')) {
      return Colors.green.shade600;
    }
    // Water sports
    else if (cat.contains('swim') ||
        cat.contains('water') ||
        cat.contains('diving')) {
      return Colors.lightBlue.shade600;
    }
    // Combat sports
    else if (cat.contains('boxing') ||
        cat.contains('martial') ||
        cat.contains('fight') ||
        cat.contains('karate') ||
        cat.contains('judo') ||
        cat.contains('mma')) {
      return Colors.red.shade800;
    }
    // Precision sports
    else if (cat.contains('golf') ||
        cat.contains('archery') ||
        cat.contains('shooting')) {
      return Colors.teal.shade600;
    }
    // Winter sports
    else if (cat.contains('ski') ||
        cat.contains('snow') ||
        cat.contains('ice') ||
        cat.contains('hockey') ||
        cat.contains('skating')) {
      return Colors.blue.shade300;
    }
    // Racket sports (not already covered by ball sports)
    else if (cat.contains('badminton') ||
        cat.contains('squash') ||
        cat.contains('racket')) {
      return Colors.yellow.shade800;
    }
    // Outdoor activities
    else if (cat.contains('hike') ||
        cat.contains('climb') ||
        cat.contains('trail') ||
        cat.contains('trek') ||
        cat.contains('mountain')) {
      return Colors.brown.shade600;
    }
    // Default case - generate a color based on hash
    else {
      final int hash = cat.hashCode.abs();
      return Color.fromARGB(
        255,
        (hash % 150) + 50,
        ((hash ~/ 10) % 150) + 50,
        ((hash ~/ 100) % 150) + 50,
      );
    }
  }

  IconData _getCategoryIcon(String category) {
    final String cat = category.toLowerCase();

    // Strength and weight training
    if (cat.contains('strength') ||
        cat.contains('weight') ||
        cat.contains('gym')) {
      return Icons.fitness_center;
    }
    // Running activities
    else if (cat.contains('run') ||
        cat.contains('jog') ||
        cat.contains('marathon')) {
      return Icons.directions_run;
    }
    // General cardio
    else if (cat.contains('cardio') ||
        cat.contains('hiit') ||
        cat.contains('aerobic')) {
      return Icons.favorite;
    }
    // Flexibility activities
    else if (cat.contains('flex') ||
        cat.contains('yoga') ||
        cat.contains('stretch')) {
      return Icons.accessibility_new;
    }
    // Basketball
    else if (cat.contains('basketball')) {
      return Icons.sports_basketball;
    }
    // Football/Soccer
    else if (cat.contains('football') || cat.contains('soccer')) {
      return Icons.sports_soccer;
    }
    // Tennis
    else if (cat.contains('tennis')) {
      return Icons.sports_tennis;
    }
    // Baseball
    else if (cat.contains('baseball')) {
      return Icons.sports_baseball;
    }
    // Volleyball
    else if (cat.contains('volleyball')) {
      return Icons.sports_volleyball;
    }
    // Golf
    else if (cat.contains('golf')) {
      return Icons.sports_golf;
    }
    // Cycling
    else if (cat.contains('cycling') ||
        cat.contains('bike') ||
        cat.contains('biking')) {
      return Icons.pedal_bike;
    }
    // Swimming
    else if (cat.contains('swim') || cat.contains('pool')) {
      return Icons.pool;
    }
    // Combat sports
    else if (cat.contains('boxing') ||
        cat.contains('martial') ||
        cat.contains('karate') ||
        cat.contains('judo') ||
        cat.contains('mma') ||
        cat.contains('fight')) {
      return Icons.sports_martial_arts;
    }
    // Winter sports
    else if (cat.contains('ski') ||
        cat.contains('snow') ||
        cat.contains('ice')) {
      return Icons.snowboarding;
    }
    // Hockey
    else if (cat.contains('hockey')) {
      return Icons.sports_hockey;
    }
    // Climbing/Hiking
    else if (cat.contains('climb') ||
        cat.contains('hike') ||
        cat.contains('trek')) {
      return Icons.terrain;
    }
    // Generic sports
    else if (cat.contains('sport')) {
      return Icons.sports;
    }
    // Handball
    else if (cat.contains('handball')) {
      return Icons.sports_handball;
    }
    // Rugby
    else if (cat.contains('rugby')) {
      return Icons.sports_rugby;
    }
    // Bodyweight exercises
    else if (cat.contains('body') || cat.contains('calisthenics')) {
      return Icons.person;
    }
    // Racket sports (not already covered)
    else if (cat.contains('badminton') ||
        cat.contains('squash') ||
        cat.contains('racket')) {
      return Icons.sports_tennis;
    }
    else if (cat.contains('stair') ) {
      return Icons.stairs;
    }
    // Default
    else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workouts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Consumer<ExercisesProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              slivers: [
                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        onChanged: (query) {
                          provider.updateSearchQuery(query);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search Exercises...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Category filters – dynamically generated from provider.categories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.categories.length,
                        itemBuilder: (context, index) {
                          final category = provider.categories[index];
                          final isSelected =
                              provider.selectedCategory == category;

                          return GestureDetector(
                            onTap: () {
                              provider.updateCategory(category);
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
                          provider.isLoading
                              ? 'Loading workouts...'
                              : 'Found ${provider.filteredWorkouts.length} workouts',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          provider.selectedCategory == 'All'
                              ? 'All Categories'
                              : provider.selectedCategory,
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
                provider.isLoading
                    ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : provider.errorMessage != null
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
                            Text(provider.errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: provider.fetchWorkouts,
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
                    : provider.filteredWorkouts.isEmpty
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
                              provider.searchQuery.isEmpty
                                  ? 'No workouts available'
                                  : 'No workouts match your search',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (provider.searchQuery.isNotEmpty ||
                                provider.selectedCategory != 'All')
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: TextButton.icon(
                                  onPressed: () {
                                    provider.updateSearchQuery('');
                                    provider.updateCategory('All');
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
                          final workout = provider.filteredWorkouts[index];
                          final description =
                              workout['description'] ?? 'No Description';
                          final category = workout['name'] ?? 'Other';
                          final difficulty =
                              workout['caloriesPerKg'] > 2
                                  ? 'Hard'
                                  : workout['caloriesPerKg'] > 1
                                  ? 'Medium'
                                  : 'Easy';

                          final Color categoryColor = _getCategoryColor(
                            category,
                          );

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => WorkoutDetailsScreen(
                                        workout: workout,
                                      ),
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
                                  // Top half with category-based color and icon
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
                                  // Bottom half with workout details
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              description,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
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
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    category,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: categoryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              _buildDifficultyIndicator(
                                                difficulty,
                                              ),
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
                        }, childCount: provider.filteredWorkouts.length),
                      ),
                    ),
              ],
            );
          },
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
