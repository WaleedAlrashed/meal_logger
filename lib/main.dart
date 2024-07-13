import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meal_logger/features/meals/views/meals_logger_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Logger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MealLoggerForm(),
    );
  }
}
