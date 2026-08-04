import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calendar_event_model.dart';
import '../models/school_calendar_mark_model.dart';
import '../models/schedule_item_model.dart';
import '../models/subject_model.dart';
import '../data/mock_school_calendar_marks.dart';
import '../data/mock_schedule.dart';
import '../data/mock_subjects.dart';

class StorageService {
  static const _photoPathKey = 'user_photo_path';
  static const _calendarEventsKey = 'calendar_events';
  static const _isDarkModeKey = 'is_dark_mode';
  static const _schoolMarksKey = 'school_calendar_marks';
  static const _scheduleItemsKey = 'schedule_items';
  static const _subjectsKey = 'subjects';

  Future<String?> getPhotoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_photoPathKey);
  }

  Future<void> savePhotoPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_photoPathKey, path);
  }

  Future<List<CalendarEventModel>> getCalendarEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_calendarEventsKey);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List;
    return list
        .map(
          (item) => CalendarEventModel(
            id: item['id'],
            title: item['title'],
            date: DateTime.parse(item['date']),
            notifyEnabled: item['notifyEnabled'] ?? true,
          ),
        )
        .toList();
  }

  Future<void> saveCalendarEvents(List<CalendarEventModel> events) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      events
          .map(
            (e) => {
              'id': e.id,
              'title': e.title,
              'date': e.date.toIso8601String(),
              'notifyEnabled': e.notifyEnabled,
            },
          )
          .toList(),
    );
    await prefs.setString(_calendarEventsKey, raw);
  }

  Future<bool> getIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkModeKey) ?? true;
  }

  Future<void> saveIsDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, isDark);
  }

  Future<List<SchoolCalendarMarkModel>> getSchoolCalendarMarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_schoolMarksKey);
    if (raw == null) return mockSchoolCalendarMarks;

    final list = jsonDecode(raw) as List;
    return list
        .map(
          (item) => SchoolCalendarMarkModel(
            id: item['id'],
            date: DateTime.parse(item['date']),
            type: SchoolCalendarMarkType.values.byName(item['type']),
            note: item['note'],
          ),
        )
        .toList();
  }

  Future<void> saveSchoolCalendarMarks(
    List<SchoolCalendarMarkModel> marks,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      marks
          .map(
            (m) => {
              'id': m.id,
              'date': m.date.toIso8601String(),
              'type': m.type.name,
              'note': m.note,
            },
          )
          .toList(),
    );
    await prefs.setString(_schoolMarksKey, raw);
  }

  Future<List<ScheduleItemModel>> getScheduleItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scheduleItemsKey);
    if (raw == null) return mockSchedule;

    final list = jsonDecode(raw) as List;
    return list
        .map(
          (item) => ScheduleItemModel(
            id: item['id'],
            groupId: item['groupId'],
            subject: item['subject'],
            professor: item['professor'],
            day: WeekDay.values.byName(item['day']),
            startTime: item['startTime'],
            endTime: item['endTime'],
            classroom: item['classroom'],
          ),
        )
        .toList();
  }

  Future<void> saveScheduleItems(List<ScheduleItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      items
          .map(
            (i) => {
              'id': i.id,
              'groupId': i.groupId,
              'subject': i.subject,
              'professor': i.professor,
              'day': i.day.name,
              'startTime': i.startTime,
              'endTime': i.endTime,
              'classroom': i.classroom,
            },
          )
          .toList(),
    );
    await prefs.setString(_scheduleItemsKey, raw);
  }

  Future<List<SubjectModel>> getSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_subjectsKey);
    if (raw == null) return mockSubjects;

    final list = jsonDecode(raw) as List;
    return list
        .map(
          (item) => SubjectModel(
            id: item['id'],
            name: item['name'],
            cuatrimestre: item['cuatrimestre'],
          ),
        )
        .toList();
  }

  Future<void> saveSubjects(List<SubjectModel> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      subjects
          .map(
            (s) => {'id': s.id, 'name': s.name, 'cuatrimestre': s.cuatrimestre},
          )
          .toList(),
    );
    await prefs.setString(_subjectsKey, raw);
  }
}
