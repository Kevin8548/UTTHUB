import '../models/user_model.dart';

class AuthService {
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
<<<<<<< HEAD
    // Simulación de autenticación UTT
=======
    // Mock: acepta cualquier credencial mientras no haya backend real
>>>>>>> 3e969c453fb40865bf3412f0927af8c6ecab8631
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
<<<<<<< HEAD
}
=======
}
>>>>>>> 3e969c453fb40865bf3412f0927af8c6ecab8631
