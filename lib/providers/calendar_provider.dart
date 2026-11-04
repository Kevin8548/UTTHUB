import 'package:flutter/material.dart';
import '../models/calendar_event_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class CalendarProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  List<CalendarEventModel> _events = [];
  bool _isLoading = false;

  List<CalendarEventModel> get events => _events;
  bool get isLoading => _isLoading;

  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();
    _events = await _storageService.getCalendarEvents();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEvent({required String title, required DateTime date}) async {
    final event = CalendarEventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: date,
    );
    _events = [..._events, event]..sort((a, b) => a.date.compareTo(b.date));
    await _storageService.saveCalendarEvents(_events);
    await _scheduleFor(event);
    notifyListeners();
  }

  Future<void> toggleNotify(CalendarEventModel event) async {
    final updated = event.copyWith(notifyEnabled: !event.notifyEnabled);
    _events = _events.map((e) => e.id == event.id ? updated : e).toList();
    await _storageService.saveCalendarEvents(_events);
    if (updated.notifyEnabled) {
      await _scheduleFor(updated);
    } else {
      await _notificationService.cancelNotification(updated.id.hashCode);
    }
    notifyListeners();
  }

  Future<void> removeEvent(CalendarEventModel event) async {
    _events = _events.where((e) => e.id != event.id).toList();
    await _storageService.saveCalendarEvents(_events);
    await _notificationService.cancelNotification(event.id.hashCode);
    notifyListeners();
  }

  Future<void> _scheduleFor(CalendarEventModel event) {
    return _notificationService.scheduleNotification(
      id: event.id.hashCode,
      title: event.title,
      body: 'Hoy tienes: ${event.title}',
      scheduledDate: event.date,
    );
  }
}
