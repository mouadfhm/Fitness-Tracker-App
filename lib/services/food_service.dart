import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FoodService {
  final String baseUrl = "https://world.openfoodfacts.org/api/v2/product/";

  Future<Map<String, dynamic>?> getFoodInfo(String barcode) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl$barcode.json"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1) {
          return data['product']; // Food details
        } else {
          if (kDebugMode) {
            print("Food not found.");
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print("API error: ${response.statusCode}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching food data: $e");
      }
      return null;
    }
  }
}
