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

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

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

    if (response.statusCode == 200 || response.statusCode == 302) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data submitted successfully!')),
        );
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
              ElevatedButton(
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
      firstDate: DateTime(2000),
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
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }
}
