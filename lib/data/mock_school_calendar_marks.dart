import '../models/school_calendar_mark_model.dart';

final mockSchoolCalendarMarks = <SchoolCalendarMarkModel>[
  SchoolCalendarMarkModel(
    id: 'c1',
    date: DateTime(2025, 9, 8),
    type: SchoolCalendarMarkType.cuatrimestreStart,
  ),
  SchoolCalendarMarkModel(
    id: 'c2',
    date: DateTime(2025, 12, 20),
    type: SchoolCalendarMarkType.cuatrimestreEnd,
  ),
  SchoolCalendarMarkModel(
    id: 'c3',
    date: DateTime(2026, 1, 5),
    type: SchoolCalendarMarkType.cuatrimestreStart,
  ),
  SchoolCalendarMarkModel(
    id: 'c4',
    date: DateTime(2026, 4, 30),
    type: SchoolCalendarMarkType.cuatrimestreEnd,
  ),
  SchoolCalendarMarkModel(
    id: 'c5',
    date: DateTime(2026, 5, 4),
    type: SchoolCalendarMarkType.cuatrimestreStart,
  ),
  SchoolCalendarMarkModel(
    id: 'c6',
    date: DateTime(2026, 8, 29),
    type: SchoolCalendarMarkType.cuatrimestreEnd,
  ),

  for (var d = 22; d <= 31; d++)
    SchoolCalendarMarkModel(
      id: 'vac_dec_$d',
      date: DateTime(2025, 12, d),
      type: SchoolCalendarMarkType.vacation,
    ),
  SchoolCalendarMarkModel(
    id: 'vac_jan_1',
    date: DateTime(2026, 1, 1),
    type: SchoolCalendarMarkType.vacation,
  ),
  SchoolCalendarMarkModel(
    id: 'vac_jan_2',
    date: DateTime(2026, 1, 2),
    type: SchoolCalendarMarkType.vacation,
  ),

  SchoolCalendarMarkModel(
    id: 'h1',
    date: DateTime(2025, 9, 16),
    type: SchoolCalendarMarkType.laborSuspension,
    note: 'Aniversario del inicio de la Independencia Nacional',
  ),
  SchoolCalendarMarkModel(
    id: 'h2',
    date: DateTime(2025, 11, 20),
    type: SchoolCalendarMarkType.laborSuspension,
    note: 'Aniversario del inicio de la Revolución Mexicana',
  ),
  SchoolCalendarMarkModel(
    id: 'h3',
    date: DateTime(2026, 2, 5),
    type: SchoolCalendarMarkType.laborSuspension,
    note: 'Aniversario de la promulgación de la Constitución',
  ),
  SchoolCalendarMarkModel(
    id: 'h4',
    date: DateTime(2026, 3, 21),
    type: SchoolCalendarMarkType.laborSuspension,
    note: 'Aniversario del natalicio de Don Benito Juárez',
  ),
  SchoolCalendarMarkModel(
    id: 'h5',
    date: DateTime(2026, 5, 1),
    type: SchoolCalendarMarkType.laborSuspension,
    note: 'Día del Trabajo',
  ),
  SchoolCalendarMarkModel(
    id: 'h6',
    date: DateTime(2026, 5, 5),
    type: SchoolCalendarMarkType.laborSuspension,
    note: 'Aniversario de la Batalla de Puebla',
  ),
];
