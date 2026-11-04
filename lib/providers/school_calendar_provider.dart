import 'package:flutter/material.dart';
import '../models/school_calendar_mark_model.dart';
import '../services/storage_service.dart';

class SchoolCalendarProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<SchoolCalendarMarkModel> _marks = [];
  bool _isLoading = false;

  List<SchoolCalendarMarkModel> get marks => _marks;
  bool get isLoading => _isLoading;

  List<SchoolCalendarMarkModel> marksForDay(DateTime day) => _marks
      .where(
        (m) =>
            m.date.year == day.year &&
            m.date.month == day.month &&
            m.date.day == day.day,
      )
      .toList();

  Future<void> loadMarks() async {
    _isLoading = true;
    notifyListeners();
    _marks = await _storageService.getSchoolCalendarMarks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMark({
    required DateTime date,
    required SchoolCalendarMarkType type,
    String? note,
  }) async {
    final mark = SchoolCalendarMarkModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      type: type,
      note: note,
    );
    _marks = [..._marks, mark];
    await _storageService.saveSchoolCalendarMarks(_marks);
    notifyListeners();
  }

  Future<void> addMarkRange({
    required DateTime start,
    required DateTime end,
    required SchoolCalendarMarkType type,
    String? note,
  }) async {
    final newMarks = <SchoolCalendarMarkModel>[];
    var current = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!current.isAfter(last)) {
      newMarks.add(
        SchoolCalendarMarkModel(
          id: '${DateTime.now().millisecondsSinceEpoch}_${current.year}${current.month}${current.day}',
          date: current,
          type: type,
          note: note,
        ),
      );
      current = current.add(const Duration(days: 1));
    }
    _marks = [..._marks, ...newMarks];
    await _storageService.saveSchoolCalendarMarks(_marks);
    notifyListeners();
  }

  Future<void> removeMark(SchoolCalendarMarkModel mark) async {
    _marks = _marks.where((m) => m.id != mark.id).toList();
    await _storageService.saveSchoolCalendarMarks(_marks);
    notifyListeners();
  }
}
