import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:meal_logger/features/meals/models/meal.dart';
import 'dart:convert';

class MealService {
  final String baseUrl = dotenv.env['GOOGLE_APP_SCRIPT_URL'] ?? '';

  Future<List<Meal>> fetchMeals() async {
    final response = await http.get(Uri.parse('$baseUrl?action=getMeals'));

    if (response.statusCode == 200 || response.statusCode == 302) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((meal) => Meal.fromJson(meal)).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<bool> submitMeal(Meal meal) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(meal.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 302;
  }
}
