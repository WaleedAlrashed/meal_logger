import 'package:flutter/material.dart';
import 'package:meal_logger/constants/assets.dart';
import 'package:meal_logger/features/meals/models/meal.dart';
import 'package:meal_logger/features/meals/services/meal_service.dart';
import 'package:meal_logger/features/meals/views/meals_table_view.dart';

class MealLoggerForm extends StatefulWidget {
  const MealLoggerForm({super.key});

  @override
  _MealLoggerFormState createState() => _MealLoggerFormState();
}

class _MealLoggerFormState extends State<MealLoggerForm> {
  final _formKey = GlobalKey<FormState>();
  String _mealName = '';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String _location = 'Home';
  final _notesController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final String date = "${_date.year}-${_date.month}-${_date.day}";
    final String time = "${_time.hour}:${_time.minute}";

    Meal meal = Meal(
      mealName: _mealName,
      date: date,
      time: time,
      location: _location,
      notes: _notesController.text,
    );

    bool success = await MealService().submitMeal(meal);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data submitted successfully!')),
        );
        _formKey.currentState!.reset();
        _notesController.clear();
        setState(() {
          _mealName = '';
          _date = DateTime.now();
          _time = TimeOfDay.now();
          _location = 'Home';
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit data!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Logger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MealsTableView()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Meal Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the meal name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _mealName = value!;
                },
              ),
              ListTile(
                title: Text('Date: ${_date.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text('Time: ${_time.format(context)}'),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: _pickTime,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                initialValue: 'Home',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
                onSaved: (value) {
                  _location = value!;
                },
              ),
              TextFormField(
                controller: _notesController,
                decoration:
                    const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitData,
                      child: const Text('Submit'),
                    ),
              Image.asset(
                Assets.meal,
                scale: 2.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(), // Disallow past dates
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null &&
        (picked.hour > _time.hour ||
            (picked.hour == _time.hour && picked.minute >= _time.minute))) {
      final minutes = picked.minute;
      final roundedMinutes =
          (minutes % 30 == 0) ? minutes : (minutes ~/ 30 + 1) * 30 % 60;
      final roundedPicked =
          TimeOfDay(hour: picked.hour, minute: roundedMinutes);
      setState(() {
        _time = roundedPicked;
      });
    }
  }
}
