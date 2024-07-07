import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_logger/features/meals/models/meal.dart';
import 'package:meal_logger/features/meals/services/meal_service.dart';

class MealsTableView extends StatefulWidget {
  const MealsTableView({super.key});

  @override
  _MealsTableViewState createState() => _MealsTableViewState();
}

class _MealsTableViewState extends State<MealsTableView> {
  late Future<List<Meal>> _meals;

  @override
  void initState() {
    super.initState();
    _meals = MealService().fetchMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals Table View'),
      ),
      body: FutureBuilder<List<Meal>>(
        future: _meals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No meals found.'));
          } else {
            return ListView(
              children: snapshot.data!.map((meal) {
                DateTime date = DateTime.parse(meal.date);
                String formattedDate = DateFormat('dd/MM/yyyy').format(date);

                String formattedTime;
                try {
                  DateTime time = DateTime.parse(meal.time);
                  formattedTime = DateFormat('HH:mm').format(time);
                } catch (e) {
                  formattedTime = 'Invalid Time';
                }

                return ListTile(
                  title: Text(meal.mealName),
                  subtitle: Text(
                      '$formattedDate - $formattedTime - ${meal.location}'),
                  trailing: Text(meal.notes),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
