import '../models/user_model.dart';

class AuthService {
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Mock: acepta cualquier credencial mientras no haya backend real
    return UserModel(
      id: '1',
      name: 'Kevin Pérez',
      email: email,
      career: 'Ingeniería en Tecnologías de la Información',
    );
  }

  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const UserModel(
      id: '1',
      name: 'Kevin Pérez',
      email: 'kevin.perez@utt.edu.mx',
      career: 'Ingeniería en Tecnologías de la Información',
    );
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
