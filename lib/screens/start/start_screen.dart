import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_theme.dart';

class _MockEvent {
  final String title;
  final DateTime date;
  const _MockEvent(this.title, this.date);
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  static final _mockEvents = [
    _MockEvent(
      'Junta de bienvenida',
      DateTime.now().add(const Duration(days: 2)),
    ),
    _MockEvent(
      'Entrega de proyecto',
      DateTime.now().add(const Duration(days: 5)),
    ),
    _MockEvent(
      'Conferencia de IA',
      DateTime.now().add(const Duration(days: 9)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        children: [
          Text('Hola 👋', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Esto es lo que tienes esta semana',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            'PRÓXIMOS EVENTOS',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _mockEvents.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final event = _mockEvents[index];
                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${event.date.day}/${event.date.month}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: colors.amber),
                      ),
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          // Sección de Mini Calendario (HU09)
          Text('CALENDARIO', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TableCalendar(
              locale: 'es_MX',
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) =>
                  _mockEvents.where((e) => isSameDay(e.date, day)).toList(),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markerDecoration: BoxDecoration(
                  color: colors.emerald,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: colors.emeraldDim,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: colors.emerald,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}