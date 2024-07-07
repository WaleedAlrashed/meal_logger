class Meal {
  final String mealName;
  final String date;
  final String time;
  final String location;
  final String notes;

  Meal({
    required this.mealName,
    required this.date,
    required this.time,
    required this.location,
    required this.notes,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      mealName: json['mealName'],
      date: json['date'],
      time: json['time'],
      location: json['location'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealName': mealName,
      'date': date,
      'time': time,
      'location': location,
      'notes': notes,
    };
  }
}
