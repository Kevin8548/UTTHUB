class CalendarEventModel {
  final String id;
  final String title;
  final DateTime date;
  final bool notifyEnabled;

  const CalendarEventModel({
    required this.id,
    required this.title,
    required this.date,
    this.notifyEnabled = true,
  });

  CalendarEventModel copyWith({bool? notifyEnabled}) {
    return CalendarEventModel(
      id: id,
      title: title,
      date: date,
      notifyEnabled: notifyEnabled ?? this.notifyEnabled,
    );
  }
}
