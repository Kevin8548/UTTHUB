import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/event_model.dart';
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

  Future<void> _showCreateEventDialog(BuildContext context) async {
    final colors = context.colors;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            'Nuevo Evento',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Título del evento'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  style: TextStyle(color: colors.textPrimary),
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locCtrl,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Ubicación / Auditorio'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: dialogCtx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text('Fecha: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && titleCtrl.text.trim().isNotEmpty && mounted) {
      final newEvent = EventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim().isEmpty ? 'Sin descripción' : descCtrl.text.trim(),
        date: selectedDate,
        location: locCtrl.text.trim().isEmpty ? 'Campus UTT' : locCtrl.text.trim(),
      );
      await context.read<EventsProvider>().addEvent(newEvent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento creado correctamente')),
        );
      }
    }
  }

  Future<void> _showEditEventDialog(BuildContext context, EventModel event) async {
    final colors = context.colors;
    final titleCtrl = TextEditingController(text: event.title);
    final descCtrl = TextEditingController(text: event.description);
    final locCtrl = TextEditingController(text: event.location);
    DateTime selectedDate = event.date;

    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            'Editar Evento',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Título del evento'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  style: TextStyle(color: colors.textPrimary),
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locCtrl,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Ubicación / Auditorio'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: dialogCtx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text('Fecha: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );

    if (updated == true && titleCtrl.text.trim().isNotEmpty && mounted) {
      final modifiedEvent = event.copyWith(
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        date: selectedDate,
        location: locCtrl.text.trim(),
      );
      await context.read<EventsProvider>().updateEvent(modifiedEvent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento actualizado correctamente')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.emerald,
        onPressed: () => _showCreateEventDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
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
                        ),
                        // Botón de edición (HU16)
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: colors.textMuted, size: 20),
                          tooltip: 'Editar evento',
                          onPressed: () => _showEditEventDialog(context, event),
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