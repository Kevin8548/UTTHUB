class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
    );
  }
}