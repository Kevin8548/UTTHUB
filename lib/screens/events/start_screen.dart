import 'package:flutter/material.dart';
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
        ],
      ),
    );
  }
}