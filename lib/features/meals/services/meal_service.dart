import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:meal_logger/features/meals/models/meal.dart';

class MealService {
  static const String baseUrl =
      'https://script.google.com/macros/s/AKfycbxSFVWmkSZGT-00fiM53vqUlHZRbrwmu30EVlzvQU8wgxh1GZj_it1yYnX4APrkBtdx/exec';

  Future<List<Meal>> fetchMeals() async {
    final response = await http.get(Uri.parse('$baseUrl?action=getMeals'));

    if (response.statusCode == 200) {
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
