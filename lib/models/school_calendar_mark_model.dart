import 'package:flutter/material.dart';

enum SchoolCalendarMarkType {
  cuatrimestreStart,
  cuatrimestreEnd,
  vacation,
  ordinaryEval,
  remedialEval,
  laborSuspension,
  extraGradesLoad,
  extraExams,
  academicMeetings,
  trainingWeek,
  propedeutico,
}

extension SchoolCalendarMarkTypeX on SchoolCalendarMarkType {
  String get label {
    switch (this) {
      case SchoolCalendarMarkType.cuatrimestreStart:
        return 'Inicio de cuatrimestre';
      case SchoolCalendarMarkType.cuatrimestreEnd:
        return 'Fin de cuatrimestre';
      case SchoolCalendarMarkType.vacation:
        return 'Vacaciones';
      case SchoolCalendarMarkType.ordinaryEval:
        return 'Evaluaciones ordinarias';
      case SchoolCalendarMarkType.remedialEval:
        return 'Evaluaciones remediales';
      case SchoolCalendarMarkType.laborSuspension:
        return 'Suspensión de labores';
      case SchoolCalendarMarkType.extraGradesLoad:
        return 'Carga de calificaciones extraordinarios';
      case SchoolCalendarMarkType.extraExams:
        return 'Exámenes extraordinarios';
      case SchoolCalendarMarkType.academicMeetings:
        return 'Reuniones académicas';
      case SchoolCalendarMarkType.trainingWeek:
        return 'Semana de capacitación';
      case SchoolCalendarMarkType.propedeutico:
        return 'Propedéutico';
    }
  }

  Color get color {
    switch (this) {
      case SchoolCalendarMarkType.cuatrimestreStart:
        return const Color(0xFF3D3D3D);
      case SchoolCalendarMarkType.cuatrimestreEnd:
        return const Color(0xFF6B6B6B);
      case SchoolCalendarMarkType.vacation:
        return const Color(0xFF2E7D32);
      case SchoolCalendarMarkType.ordinaryEval:
        return const Color(0xFF1976D2);
      case SchoolCalendarMarkType.remedialEval:
        return const Color(0xFFFBC02D);
      case SchoolCalendarMarkType.laborSuspension:
        return const Color(0xFFF57C00);
      case SchoolCalendarMarkType.extraGradesLoad:
        return const Color(0xFFC62828);
      case SchoolCalendarMarkType.extraExams:
        return const Color(0xFF5E35B1);
      case SchoolCalendarMarkType.academicMeetings:
        return const Color(0xFFC2185B);
      case SchoolCalendarMarkType.trainingWeek:
        return const Color(0xFFB39DDB);
      case SchoolCalendarMarkType.propedeutico:
        return const Color(0xFF26A69A);
    }
  }
}

class SchoolCalendarMarkModel {
  final String id;
  final DateTime date;
  final SchoolCalendarMarkType type;
  final String? note;

  const SchoolCalendarMarkModel({
    required this.id,
    required this.date,
    required this.type,
    this.note,
  });
}
