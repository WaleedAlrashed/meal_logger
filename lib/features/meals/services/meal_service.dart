import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meal_logger/features/meals/models/meal.dart';

class MealService {
  final Dio _dio;
  final CacheOptions _cacheOptions;
  final String baseUrl = dotenv.env['GOOGLE_APP_SCRIPT_URL'] ?? '';

  MealService()
      : _dio = Dio(),
        _cacheOptions = CacheOptions(
          store: MemCacheStore(),
          policy: CachePolicy.forceCache,
          maxStale: const Duration(days: 1),
        ) {
    _dio.interceptors.add(DioCacheInterceptor(options: _cacheOptions));
  }

  Future<List<Meal>> fetchMeals() async {
    try {
      final response = await _dio.get(
        '$baseUrl?action=getMeals',
        options: _cacheOptions.toOptions(),
      );

      if (response.statusCode == 200) {
        // Ensure the response data is a list
        if (response.data is List) {
          List<dynamic> jsonResponse = response.data;
          return jsonResponse.map((meal) => Meal.fromJson(meal)).toList();
        } else {
          throw Exception('Response data is not a list');
        }
      } else {
        throw Exception('Failed to load meals');
      }
    } catch (e) {
      throw Exception('Failed to load meals: $e');
    }
  }

  Future<bool> submitMeal(Meal meal) async {
    final response = await _dio.post(
      baseUrl,
      data: meal.toJson(),
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    return response.statusCode == 200 || response.statusCode == 302;
  }
}
