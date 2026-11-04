import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/school_calendar_provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/school_calendar_mark_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<_DynamicCalendarTabState> _personalKey = GlobalKey();
  final GlobalKey<_OfficialCalendarTabState> _officialKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().loadEvents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.emerald,
          unselectedLabelColor: colors.textMuted,
          indicatorColor: colors.emerald,
          tabs: const [
            Tab(text: 'Mis fechas'),
            Tab(text: 'Oficial'),
          ],
        ),
      ),
      floatingActionButton: _buildFab(colors),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DynamicCalendarTab(key: _personalKey),
          _OfficialCalendarTab(key: _officialKey),
        ],
      ),
    );
  }

  Widget? _buildFab(AppColorScheme colors) {
    if (_tabController.index == 0) {
      return FloatingActionButton(
        backgroundColor: colors.emerald,
        onPressed: () => _personalKey.currentState?.openAddDialog(),
        child: const Icon(Icons.add, color: Colors.black),
      );
    }
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        if (!adminProvider.isAdminMode) return const SizedBox.shrink();
        return FloatingActionButton(
          backgroundColor: colors.amber,
          onPressed: () => _officialKey.currentState?.addRangeDialog(),
          child: const Icon(Icons.date_range, color: Colors.black),
        );
      },
    );
  }
}

// ---------- MIS FECHAS ----------

class _DynamicCalendarTab extends StatefulWidget {
  const _DynamicCalendarTab({super.key});

  @override
  State<_DynamicCalendarTab> createState() => _DynamicCalendarTabState();
}

class _DynamicCalendarTabState extends State<_DynamicCalendarTab> {
  DateTime _focusedDay = DateTime.now();
  bool _showOfficialMarks = true;

  void openAddDialog() => _addEventDialog(_focusedDay);

  Future<void> _addEventDialog(DateTime baseDate) async {
    final colors = context.colors;
    final controller = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text('Nueva fecha', style: TextStyle(color: colors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: colors.textPrimary),
          decoration: const InputDecoration(hintText: 'Ej. Examen de Redes'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Siguiente'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (title == null || title.trim().isEmpty || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );

    if (time == null || !mounted) return;

    final fullDate = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      time.hour,
      time.minute,
    );

    context.read<CalendarProvider>().addEvent(
      title: title.trim(),
      date: fullDate,
    );
  }

  // Confirmar antes de eliminar una fecha personal
  Future<void> _confirmDeleteEvent(
    BuildContext sheetContext,
    dynamic event,
    CalendarProvider calendarProvider,
  ) async {
    final colors = context.colors;

    final confirmed = await showDialog<bool>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          'Eliminar fecha',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${event.title}"? Esta acción no se puede deshacer.',
          style: TextStyle(color: colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      calendarProvider.removeEvent(event);

      if (sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }
    }
  }

  Future<void> _showDayDetails(DateTime day) async {
    final colors = context.colors;
    final calendarProvider = context.read<CalendarProvider>();
    final schoolCalendarProvider = context.read<SchoolCalendarProvider>();

    final personalEvents = calendarProvider.events
        .where((e) => isSameDay(e.date, day))
        .toList();

    final officialMarks = _showOfficialMarks
        ? schoolCalendarProvider.marksForDay(day)
        : <SchoolCalendarMarkModel>[];

    await showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${day.day}/${day.month}/${day.year}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),

                if (personalEvents.isEmpty && officialMarks.isEmpty)
                  Text(
                    'Sin fechas este día',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                ...personalEvents.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors.emerald,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: colors.textPrimary),
                              ),
                              Text(
                                '${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),

                        // Activar o desactivar notificaciones
                        IconButton(
                          icon: Icon(
                            event.notifyEnabled
                                ? Icons.notifications_active
                                : Icons.notifications_none,
                            color: event.notifyEnabled
                                ? colors.emerald
                                : colors.textMuted,
                            size: 20,
                          ),
                          onPressed: () {
                            calendarProvider.toggleNotify(event);
                          },
                        ),

                        // Eliminar fecha con confirmación
                        IconButton(
                          tooltip: 'Eliminar fecha',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _confirmDeleteEvent(
                            sheetContext,
                            event,
                            calendarProvider,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                ...officialMarks.map(
                  (mark) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: mark.type.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${mark.type.label} (oficial)',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _addEventDialog(day);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar fecha'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    final schoolCalendarProvider = context.watch<SchoolCalendarProvider>();
    final colors = context.colors;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: TableCalendar(
              locale: 'es_MX',
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              onPageChanged: (focused) {
                setState(() => _focusedDay = focused);
              },
              onDaySelected: (selected, focused) {
                setState(() => _focusedDay = focused);
                _showDayDetails(selected);
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final hasPersonal = calendarProvider.events.any(
                    (e) => isSameDay(e.date, day),
                  );

                  final officialMarks = _showOfficialMarks
                      ? schoolCalendarProvider.marksForDay(day)
                      : <SchoolCalendarMarkModel>[];

                  final hasOfficial = officialMarks.isNotEmpty;

                  if (!hasPersonal && !hasOfficial) return null;

                  final mainColor = hasPersonal
                      ? colors.emerald
                      : officialMarks.first.type.color;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: mainColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (hasPersonal && hasOfficial)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: officialMarks.first.type.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.surface,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          Material(
            color: colors.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.border),
            ),
            child: SwitchListTile(
              activeColor: colors.emerald,
              dense: true,
              title: Text(
                'Mostrar fechas académicas',
                style: TextStyle(color: colors.textPrimary),
              ),
              value: _showOfficialMarks,
              onChanged: (value) {
                setState(() => _showOfficialMarks = value);
              },
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              'Toca un día para ver o agregar tus fechas',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- OFICIAL ----------

class _OfficialCalendarTab extends StatefulWidget {
  const _OfficialCalendarTab({super.key});

  @override
  State<_OfficialCalendarTab> createState() => _OfficialCalendarTabState();
}

class _OfficialCalendarTabState extends State<_OfficialCalendarTab> {
  DateTime _focusedDay = DateTime(2025, 9, 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchoolCalendarProvider>().loadMarks();
    });
  }

  Future<void> _addMarkDialog(DateTime day) async {
    final colors = context.colors;
    SchoolCalendarMarkType selectedType = SchoolCalendarMarkType.ordinaryEval;
    final noteController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            'Marca para ${day.day}/${day.month}/${day.year}',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<SchoolCalendarMarkType>(
                value: selectedType,
                isExpanded: true,
                dropdownColor: colors.surface,
                items: SchoolCalendarMarkType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: type.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            type.label,
                            style: TextStyle(color: colors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                style: TextStyle(color: colors.textPrimary),
                decoration: const InputDecoration(hintText: 'Nota (opcional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      context.read<SchoolCalendarProvider>().addMark(
        date: day,
        type: selectedType,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
      );
    }

    noteController.dispose();
  }

  Future<void> addRangeDialog() async {
    final colors = context.colors;
    DateTime? startDate;
    DateTime? endDate;
    SchoolCalendarMarkType selectedType = SchoolCalendarMarkType.vacation;
    final noteController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            'Agregar rango de fechas',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RangeDateTile(
                  label: 'Desde',
                  date: startDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: DateTime(2025, 9, 1),
                      firstDate: DateTime(2025, 8, 1),
                      lastDate: DateTime(2026, 9, 30),
                    );

                    if (picked != null) {
                      setDialogState(() => startDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _RangeDateTile(
                  label: 'Hasta',
                  date: endDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: startDate ?? DateTime(2025, 9, 1),
                      firstDate: startDate ?? DateTime(2025, 8, 1),
                      lastDate: DateTime(2026, 9, 30),
                    );

                    if (picked != null) {
                      setDialogState(() => endDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButton<SchoolCalendarMarkType>(
                  value: selectedType,
                  isExpanded: true,
                  dropdownColor: colors.surface,
                  items: SchoolCalendarMarkType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: type.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              type.label,
                              style: TextStyle(color: colors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Nota (opcional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed:
                  (startDate != null &&
                      endDate != null &&
                      !endDate!.isBefore(startDate!))
                  ? () {
                      context.read<SchoolCalendarProvider>().addMarkRange(
                        start: startDate!,
                        end: endDate!,
                        type: selectedType,
                        note: noteController.text.trim().isEmpty
                            ? null
                            : noteController.text.trim(),
                      );
                      Navigator.pop(dialogContext);
                    }
                  : null,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    noteController.dispose();
  }

  Future<void> _showDayDetails(DateTime day) async {
    final colors = context.colors;
    final schoolCalendarProvider = context.read<SchoolCalendarProvider>();
    final adminProvider = context.read<AdminProvider>();
    final dayMarks = schoolCalendarProvider.marksForDay(day);

    await showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${day.day}/${day.month}/${day.year}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),

                if (dayMarks.isEmpty)
                  Text(
                    'Sin marcas este día',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ...dayMarks.map(
                    (mark) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: mark.type.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mark.type.label,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: colors.textPrimary),
                                ),
                                if (mark.note != null)
                                  Text(
                                    mark.note!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          if (adminProvider.isAdminMode)
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: colors.textMuted,
                                size: 20,
                              ),
                              onPressed: () {
                                schoolCalendarProvider.removeMark(mark);
                                Navigator.pop(sheetContext);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                if (adminProvider.isAdminMode) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _addMarkDialog(day);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar marca'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context, AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LEYENDA', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 4.3,
            children: SchoolCalendarMarkType.values.map((type) {
              return Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: type.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      type.label,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schoolCalendarProvider = context.watch<SchoolCalendarProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final colors = context.colors;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: TableCalendar(
              locale: 'es_MX',
              firstDay: DateTime.utc(2025, 8, 1),
              lastDay: DateTime.utc(2026, 9, 30),
              focusedDay: _focusedDay,
              onPageChanged: (focused) {
                setState(() => _focusedDay = focused);
              },
              onDaySelected: (selected, focused) {
                _showDayDetails(selected);
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final dayMarks = schoolCalendarProvider.marksForDay(day);

                  if (dayMarks.isEmpty) return null;

                  return Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: dayMarks.first.type.color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 14),

          Center(
            child: Text(
              adminProvider.isAdminMode
                  ? 'Toca un día para ver o editar sus marcas'
                  : 'Toca un día para ver a qué corresponde',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 18),

          _buildLegend(context, colors),
        ],
      ),
    );
  }
}

class _RangeDateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _RangeDateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: colors.textMuted),
            const SizedBox(width: 8),
            Text(
              date == null
                  ? label
                  : '$label: ${date!.day}/${date!.month}/${date!.year}',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
