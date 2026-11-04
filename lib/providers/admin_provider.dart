import 'package:flutter/material.dart';

/// Temporal: es solo un switch local para poder probar el modo edición.
/// Cuando conectes el backend, esto se reemplaza por el rol real del usuario.
class AdminProvider extends ChangeNotifier {
  bool _isAdminMode = false;
  bool get isAdminMode => _isAdminMode;

  void toggle(bool value) {
    _isAdminMode = value;
    notifyListeners();
  }
}
