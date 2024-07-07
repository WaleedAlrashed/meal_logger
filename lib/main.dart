import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
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
      home: const MealLogger(),
    );
  }
}

class MealLogger extends StatefulWidget {
  const MealLogger({super.key});

  @override
  _MealLoggerState createState() => _MealLoggerState();
}

class _MealLoggerState extends State<MealLogger> {
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

    const url =
        'https://script.google.com/macros/s/AKfycbzIDXmc2Q-Fb93MvtJbFOqZEKmJqsiaCy5SQW-dHVtNyRwBHSTbeap7s5Pp5W1zVzVk/exec';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'mealName': _mealName,
        'date': date,
        'time': time,
        'location': _location,
        'notes': _notesController.text,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200 || response.statusCode == 302) {
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
