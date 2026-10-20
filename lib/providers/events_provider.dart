import 'package:flutter/material.dart';
import '../data/mock_events.dart';
import '../models/event_model.dart';
import '../services/notification_service.dart';

class EventsProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<EventModel> _events = [];
  bool _isLoading = false;
  final Set<String> _notified = {};

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  bool isNotified(String eventId) => _notified.contains(eventId);

  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _events = List.from(mockEvents)..sort((a, b) => a.date.compareTo(b.date));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEvent(EventModel event) async {
    _events.add(event);
    _events.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  Future<void> updateEvent(EventModel updated) async {
    final index = _events.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _events[index] = updated;
      _events.sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
    }
  }

  Future<void> removeEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
    if (_notified.contains(eventId)) {
      await _notificationService.cancelNotification(eventId.hashCode);
      _notified.remove(eventId);
    }
    notifyListeners();
  }

  Future<void> toggleNotify(EventModel event) async {
    if (_notified.contains(event.id)) {
      await _notificationService.cancelNotification(event.id.hashCode);
      _notified.remove(event.id);
    } else {
      await _notificationService.scheduleNotification(
        id: event.id.hashCode,
        title: event.title,
        body: '${event.location} · ${_formatDate(event.date)}',
        scheduledDate: event.date.subtract(const Duration(hours: 1)),
      );
      _notified.add(event.id);
    }
    notifyListeners();
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}