import 'package:flutter/material.dart';
import '../data/mock_groups.dart';
import '../models/group_model.dart';
import '../models/schedule_item_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  List<ScheduleItemModel> _items = [];
  bool _isLoading = false;
  final Set<String> _notified = {};
  String _selectedGroupId = mockGroups.first.id;

  List<GroupModel> get groups => mockGroups;
  String get selectedGroupId => _selectedGroupId;
  bool get isLoading => _isLoading;
  bool isNotified(String itemId) => _notified.contains(itemId);

  List<ScheduleItemModel> get _selectedGroupItems =>
      _items.where((i) => i.groupId == _selectedGroupId).toList();

  bool get allNotifiedForSelectedGroup {
    final groupItems = _selectedGroupItems;
    if (groupItems.isEmpty) return false;
    return groupItems.every((i) => _notified.contains(i.id));
  }

  void selectGroup(String groupId) {
    _selectedGroupId = groupId;
    notifyListeners();
  }

  Future<void> loadSchedule() async {
    _isLoading = true;
    notifyListeners();
    _items = await _storageService.getScheduleItems();
    _isLoading = false;
    notifyListeners();
  }

  List<ScheduleItemModel> itemsForDay(WeekDay day) =>
      _selectedGroupItems.where((i) => i.day == day).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

  Future<void> addItem({
    required String subject,
    required String professor,
    required WeekDay day,
    required String startTime,
    required String endTime,
    required String classroom,
  }) async {
    final item = ScheduleItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: _selectedGroupId,
      subject: subject,
      professor: professor,
      day: day,
      startTime: startTime,
      endTime: endTime,
      classroom: classroom,
    );
    _items = [..._items, item];
    await _storageService.saveScheduleItems(_items);
    notifyListeners();
  }

  Future<void> updateItem(ScheduleItemModel item) async {
    _items = _items.map((i) => i.id == item.id ? item : i).toList();
    await _storageService.saveScheduleItems(_items);
    if (_notified.contains(item.id)) {
      await _notificationService.cancelNotification(item.id.hashCode);
      await _scheduleNotificationFor(item);
    }
    notifyListeners();
  }

  Future<void> removeItem(ScheduleItemModel item) async {
    _items = _items.where((i) => i.id != item.id).toList();
    await _storageService.saveScheduleItems(_items);
    if (_notified.contains(item.id)) {
      await _notificationService.cancelNotification(item.id.hashCode);
      _notified.remove(item.id);
    }
    notifyListeners();
  }

  Future<void> toggleNotify(ScheduleItemModel item) async {
    if (_notified.contains(item.id)) {
      await _notificationService.cancelNotification(item.id.hashCode);
      _notified.remove(item.id);
    } else {
      await _scheduleNotificationFor(item);
      _notified.add(item.id);
    }
    notifyListeners();
  }

  Future<void> toggleAllForSelectedGroup() async {
    final groupItems = _selectedGroupItems;
    final shouldEnable = !allNotifiedForSelectedGroup;

    for (final item in groupItems) {
      if (shouldEnable && !_notified.contains(item.id)) {
        await _scheduleNotificationFor(item);
        await Future.delayed(const Duration(milliseconds: 150));
        _notified.add(item.id);
      } else if (!shouldEnable && _notified.contains(item.id)) {
        await _notificationService.cancelNotification(item.id.hashCode);
        await Future.delayed(const Duration(milliseconds: 150));
        _notified.remove(item.id);
      }
    }
    notifyListeners();
  }

  Future<void> _scheduleNotificationFor(ScheduleItemModel item) {
    final parts = item.startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final notifyMinutes = hour * 60 + minute - 5;
    final normalized = notifyMinutes < 0
        ? notifyMinutes + (24 * 60)
        : notifyMinutes;

    return _notificationService.scheduleWeeklyNotification(
      id: item.id.hashCode,
      title: item.subject,
      body: 'En 5 min · ${item.classroom}',
      weekday: _weekdayNumber(item.day),
      hour: normalized ~/ 60,
      minute: normalized % 60,
    );
  }

  int _weekdayNumber(WeekDay day) {
    switch (day) {
      case WeekDay.monday:
        return DateTime.monday;
      case WeekDay.tuesday:
        return DateTime.tuesday;
      case WeekDay.wednesday:
        return DateTime.wednesday;
      case WeekDay.thursday:
        return DateTime.thursday;
      case WeekDay.friday:
        return DateTime.friday;
    }
  }
}