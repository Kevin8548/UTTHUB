import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _photoPath;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get photoPath => _photoPath;

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.login(email: email, password: password);
      _photoPath = await _storageService.getPhotoPath();
      _error = null;
    } catch (_) {
      _error = 'No se pudo iniciar sesión';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.getCurrentUser();
      _photoPath = await _storageService.getPhotoPath();
      _error = null;
    } catch (_) {
      _error = 'No se pudo cargar el perfil';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickProfilePhoto({required ImageSource source}) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final savedImage = await File(
      picked.path,
    ).copy('${directory.path}/profile_photo.jpg');

    _photoPath = savedImage.path;
    await _storageService.savePhotoPath(_photoPath!);
    notifyListeners();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}