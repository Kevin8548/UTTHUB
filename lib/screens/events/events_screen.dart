import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/events_provider.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      body: eventsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : eventsProvider.events.isEmpty
          ? Center(
              child: Text(
                'No hay eventos programados',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : SafeArea(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: eventsProvider.events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final event = eventsProvider.events[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${event.date.day}/${event.date.month} · ${event.location}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: colors.amber),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}