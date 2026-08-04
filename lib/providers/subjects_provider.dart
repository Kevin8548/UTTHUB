import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../services/storage_service.dart';

class SubjectsProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<SubjectModel> _subjects = [];
  bool _isLoading = false;
  final int _currentCuatrimestre =
      3; // placeholder hasta conectar con datos reales del alumno

  bool get isLoading => _isLoading;
  int get currentCuatrimestre => _currentCuatrimestre;

  Map<int, List<SubjectModel>> get subjectsByCuatrimestre {
    final map = <int, List<SubjectModel>>{};
    for (final subject in _subjects) {
      map.putIfAbsent(subject.cuatrimestre, () => []).add(subject);
    }
    return map;
  }

  Future<void> loadSubjects() async {
    _isLoading = true;
    notifyListeners();
    _subjects = await _storageService.getSubjects();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSubject({
    required String name,
    required int cuatrimestre,
  }) async {
    final subject = SubjectModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      cuatrimestre: cuatrimestre,
    );
    _subjects = [..._subjects, subject];
    await _storageService.saveSubjects(_subjects);
    notifyListeners();
  }

  Future<void> updateSubject(SubjectModel subject) async {
    _subjects = _subjects.map((s) => s.id == subject.id ? subject : s).toList();
    await _storageService.saveSubjects(_subjects);
    notifyListeners();
  }

  Future<void> removeSubject(SubjectModel subject) async {
    _subjects = _subjects.where((s) => s.id != subject.id).toList();
    await _storageService.saveSubjects(_subjects);
    notifyListeners();
  }
}
