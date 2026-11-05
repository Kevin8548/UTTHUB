import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/schedule_item_model.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/admin_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _days = [
    WeekDay.monday,
    WeekDay.tuesday,
    WeekDay.wednesday,
    WeekDay.thursday,
    WeekDay.friday,
  ];
  static const _dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now().weekday;
    final initialIndex = (today >= 1 && today <= 5) ? today - 1 : 0;
    _tabController = TabController(
      length: _days.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().loadSchedule();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _itemDialog({
    ScheduleItemModel? existing,
    required WeekDay day,
  }) async {
    final colors = context.colors;
    final subjectController = TextEditingController(
      text: existing?.subject ?? '',
    );
    final professorController = TextEditingController(
      text: existing?.professor ?? '',
    );
    final classroomController = TextEditingController(
      text: existing?.classroom ?? '',
    );
    TimeOfDay startTime = existing != null
        ? TimeOfDay(
            hour: int.parse(existing.startTime.split(':')[0]),
            minute: int.parse(existing.startTime.split(':')[1]),
          )
        : const TimeOfDay(hour: 7, minute: 0);
    TimeOfDay endTime = existing != null
        ? TimeOfDay(
            hour: int.parse(existing.endTime.split(':')[0]),
            minute: int.parse(existing.endTime.split(':')[1]),
          )
        : const TimeOfDay(hour: 8, minute: 0);

    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            existing == null ? 'Nueva clase' : 'Editar clase',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: subjectController,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: const InputDecoration(hintText: 'Materia'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: professorController,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: const InputDecoration(hintText: 'Profesor'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: classroomController,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: const InputDecoration(hintText: 'Salón'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: dialogContext,
                            initialTime: startTime,
                          );
                          if (picked != null)
                            setDialogState(() => startTime = picked);
                        },
                        child: Text('Inicio: ${fmt(startTime)}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: dialogContext,
                            initialTime: endTime,
                          );
                          if (picked != null)
                            setDialogState(() => endTime = picked);
                        },
                        child: Text('Fin: ${fmt(endTime)}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: subjectController.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !mounted) return;

    final scheduleProvider = context.read<ScheduleProvider>();
    if (existing == null) {
      await scheduleProvider.addItem(
        subject: subjectController.text.trim(),
        professor: professorController.text.trim().isEmpty
            ? 'Por asignar'
            : professorController.text.trim(),
        day: day,
        startTime: fmt(startTime),
        endTime: fmt(endTime),
        classroom: classroomController.text.trim().isEmpty
            ? 'Por asignar'
            : classroomController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Clase "${subjectController.text.trim()}" creada con éxito',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colors.surface,
          ),
        );
      }
    } else {
      await scheduleProvider.updateItem(
        existing.copyWith(
          subject: subjectController.text.trim(),
          professor: professorController.text.trim().isEmpty
              ? 'Por asignar'
              : professorController.text.trim(),
          day: day,
          startTime: fmt(startTime),
          endTime: fmt(endTime),
          classroom: classroomController.text.trim().isEmpty
              ? 'Por asignar'
              : classroomController.text.trim(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Clase "${subjectController.text.trim()}" actualizada con éxito',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colors.surface,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horario'),
        actions: [
          IconButton(
            tooltip: scheduleProvider.allNotifiedForSelectedGroup
                ? 'Desactivar todas'
                : 'Activar todas',
            icon: Icon(
              scheduleProvider.allNotifiedForSelectedGroup
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
              color: scheduleProvider.allNotifiedForSelectedGroup
                  ? colors.emerald
                  : colors.textMuted,
            ),
            onPressed: () => scheduleProvider.toggleAllForSelectedGroup(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.emerald,
          unselectedLabelColor: colors.textMuted,
          indicatorColor: colors.emerald,
          tabs: _dayLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      floatingActionButton: adminProvider.isAdminMode
          ? FloatingActionButton(
              backgroundColor: colors.emerald,
              onPressed: () => _itemDialog(day: _days[_tabController.index]),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: scheduleProvider.groups.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final group = scheduleProvider.groups[index];
                  final selected = group.id == scheduleProvider.selectedGroupId;
                  return GestureDetector(
                    onTap: () => scheduleProvider.selectGroup(group.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? colors.emerald : colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? colors.emerald : colors.border,
                        ),
                      ),
                      child: Text(
                        group.name,
                        style: TextStyle(
                          color: selected ? Colors.black : colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                scheduleProvider.groups
                    .firstWhere((g) => g.id == scheduleProvider.selectedGroupId)
                    .career,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: scheduleProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: _days.map((day) {
                      final items = scheduleProvider.itemsForDay(day);
                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            'Sin clases',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final notified = scheduleProvider.isNotified(item.id);

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: colors.emerald,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.startTime} - ${item.endTime}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: colors.amber),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.subject,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.classroom} · ${item.professor}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                if (adminProvider.isAdminMode)
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: colors.textMuted,
                                    ),
                                    onPressed: () =>
                                        _itemDialog(existing: item, day: day),
                                  ),
                                if (adminProvider.isAdminMode)
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: colors.textMuted,
                                    ),
                                    onPressed: () =>
                                        scheduleProvider.removeItem(item),
                                  ),
                                IconButton(
                                  icon: Icon(
                                    notified
                                        ? Icons.notifications_active
                                        : Icons.notifications_none,
                                    color: notified
                                        ? colors.emerald
                                        : colors.textMuted,
                                  ),
                                  onPressed: () =>
                                      scheduleProvider.toggleNotify(item),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}