import '../models/event_model.dart';

final mockEvents = [
  EventModel(
    id: '1',
    title: 'Junta de bienvenida',
    description: 'Presentación de coordinadores y reglamento del cuatrimestre.',
    date: DateTime.now().add(const Duration(days: 2, hours: 10)),
    location: 'Auditorio principal',
  ),
  EventModel(
    id: '2',
    title: 'Entrega de proyecto integrador',
    description: 'Entrega final ante panel de evaluación.',
    date: DateTime.now().add(const Duration(days: 5, hours: 9)),
    location: 'Sala de proyectos',
  ),
  EventModel(
    id: '3',
    title: 'Conferencia de IA',
    description: 'Charla invitada sobre modelos generativos.',
    date: DateTime.now().add(const Duration(days: 9, hours: 12)),
    location: 'Auditorio principal',
  ),
];