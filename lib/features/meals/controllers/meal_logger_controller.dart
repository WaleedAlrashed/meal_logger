import 'package:flutter/material.dart';
import 'package:meal_logger/features/meals/models/meal.dart';
import 'package:meal_logger/features/meals/services/meal_service.dart';

class MealLoggerController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String mealName = '';
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  String location = 'Home';
  final TextEditingController notesController = TextEditingController();
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  VoidCallback? onDateTimeChanged;

  Future<bool> submitData(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    formKey.currentState!.save();

    isLoading.value = true;

    final String formattedDate = "${date.year}-${date.month}-${date.day}";
    final String formattedTime = "${time.hour}:${time.minute}";

    Meal meal = Meal(
      mealName: mealName,
      date: formattedDate,
      time: formattedTime,
      location: location,
      notes: notesController.text,
    );

    bool success = await MealService().submitMeal(meal);

    isLoading.value = false;

    if (success) {
      if (formKey.currentState != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data submitted successfully!')),
        );
        formKey.currentState!.reset();
        notesController.clear();
        mealName = '';
        date = DateTime.now();
        time = TimeOfDay.now();
        location = 'Home';
        onDateTimeChanged?.call();
      }
    } else {
      if (formKey.currentState != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit data!')),
        );
      }
    }

    return success;
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now(), // Disallow past dates
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != date) {
      date = picked;
      onDateTimeChanged?.call();
    }
  }

  Future<void> pickTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final minutes = picked.minute;
      final roundedMinutes =
          (minutes % 30 == 0) ? minutes : (minutes ~/ 30 + 1) * 30 % 60;
      final roundedPicked =
          TimeOfDay(hour: picked.hour, minute: roundedMinutes);
      time = roundedPicked;
      onDateTimeChanged?.call();
    }
  }
}
