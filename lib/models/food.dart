class Food {
  final int id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final int isFavorite;

  Food({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.isFavorite = 0,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    // Check if the JSON contains nutriments (Open Food Facts API format)
    if (json.containsKey('nutriments')) {
      final nutriments = json['nutriments'] ?? {};
      return Food(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id'].toString()) ?? 0,
        // Use 'brands' as name for Open Food Facts, change as needed
        name: json['brands'] ?? 'Unknown',
        calories: nutriments['energy-kcal_100g'] is num
            ? (nutriments['energy-kcal_100g'] as num).toDouble()
            : double.tryParse(nutriments['energy-kcal_100g']?.toString() ?? '') ?? 0.0,
        protein: nutriments['proteins_100g'] is num
            ? (nutriments['proteins_100g'] as num).toDouble()
            : double.tryParse(nutriments['proteins_100g']?.toString() ?? '') ?? 0.0,
        carbs: nutriments['carbohydrates_100g'] is num
            ? (nutriments['carbohydrates_100g'] as num).toDouble()
            : double.tryParse(nutriments['carbohydrates_100g']?.toString() ?? '') ?? 0.0,
        fats: nutriments['fat_100g'] is num
            ? (nutriments['fat_100g'] as num).toDouble()
            : double.tryParse(nutriments['fat_100g']?.toString() ?? '') ?? 0.0,
      );
    } else {
      // Otherwise, assume the JSON is from your local foods table
      return Food(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id'].toString()) ?? 0,
        name: json['name'] ?? 'Unknown',
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fats: (json['fats'] as num).toDouble(),
        isFavorite: json['is_favorite'] ?? 0,
      );
    }
  }
}
