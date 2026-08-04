enum WeekDay { monday, tuesday, wednesday, thursday, friday }

class ScheduleItemModel {
  final String id;
  final String groupId;
  final String subject;
  final String professor;
  final WeekDay day;
  final String startTime;
  final String endTime;
  final String classroom;

  const ScheduleItemModel({
    required this.id,
    required this.groupId,
    required this.subject,
    required this.professor,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.classroom,
  });

  ScheduleItemModel copyWith({
    String? subject,
    String? professor,
    WeekDay? day,
    String? startTime,
    String? endTime,
    String? classroom,
  }) {
    return ScheduleItemModel(
      id: id,
      groupId: groupId,
      subject: subject ?? this.subject,
      professor: professor ?? this.professor,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      classroom: classroom ?? this.classroom,
    );
  }
}
