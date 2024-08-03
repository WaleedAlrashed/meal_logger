import 'package:flutter/material.dart';
import 'package:meal_logger/constants/assets.dart';
import 'package:meal_logger/features/meals/views/meals_table_view.dart';
import 'package:meal_logger/constants/meals_suggestions_list.dart';
import 'package:meal_logger/features/meals/controllers/meal_logger_controller.dart';

class MealLoggerForm extends StatefulWidget {
  const MealLoggerForm({super.key});

  @override
  _MealLoggerFormState createState() => _MealLoggerFormState();
}

class _MealLoggerFormState extends State<MealLoggerForm> {
  final MealLoggerController _controller = MealLoggerController();

  @override
  void initState() {
    super.initState();
    _controller.onDateTimeChanged = () {
      setState(() {});
    };
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
          key: _controller.formKey,
          child: ListView(
            children: <Widget>[
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return mealsSuggestionsList.where(
                    (String option) {
                      return option.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          );
                    },
                  );
                },
                onSelected: (String selection) {
                  setState(() {
                    _controller.mealName = selection;
                  });
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: 'Meal Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the meal name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _controller.mealName = value!;
                    },
                  );
                },
              ),
              ListTile(
                title: Text(
                    'Date: ${_controller.date.year}-${_controller.date.month}-${_controller.date.day}'),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  await _controller.pickDate(context);
                },
              ),
              ListTile(
                title: Text('Time: ${_controller.time.format(context)}'),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  await _controller.pickTime(context);
                },
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
                  _controller.location = value!;
                },
              ),
              TextFormField(
                controller: _controller.notesController,
                decoration:
                    const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.isLoading,
                builder: (context, isLoading, child) {
                  return isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            bool success =
                                await _controller.submitData(context);
                            if (success) {
                              setState(() {});
                            }
                          },
                          child: const Text('Submit'),
                        );
                },
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
}
