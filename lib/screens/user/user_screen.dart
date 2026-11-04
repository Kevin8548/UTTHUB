import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import 'change_password_screen.dart';
import '../../providers/admin_provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.user == null) userProvider.loadUser();
    });
  }

  void _showPhotoOptions() {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: colors.textPrimary),
                title: Text(
                  'Tomar foto',
                  style: TextStyle(color: colors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<UserProvider>().pickProfilePhoto(
                    source: ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: colors.textPrimary),
                title: Text(
                  'Elegir de galería',
                  style: TextStyle(color: colors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<UserProvider>().pickProfilePhoto(
                    source: ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Usuario')),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? Center(child: Text(userProvider.error ?? 'Sin datos'))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: colors.surface,
                            backgroundImage: userProvider.photoPath != null
                                ? FileImage(File(userProvider.photoPath!))
                                : null,
                            child: userProvider.photoPath == null
                                ? Text(
                                    user.name.substring(0, 1),
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: colors.emerald,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colors.emerald,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      user.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      user.career,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _InfoTile(label: 'Correo', value: user.email),
                  const SizedBox(height: 12),
                  _InfoTile(label: 'Matrícula', value: user.id),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      ),
                      child: const Text('Cambiar contraseña'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return Material(
                        color: colors.surface,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colors.border),
                        ),
                        child: SwitchListTile(
                          activeColor: colors.emerald,
                          title: Text(
                            'Modo oscuro',
                            style: TextStyle(color: colors.textPrimary),
                          ),
                          subtitle: Text(
                            themeProvider.isDark ? 'Activado' : 'Desactivado',
                            style: TextStyle(color: colors.textMuted),
                          ),
                          value: themeProvider.isDark,
                          onChanged: (value) => themeProvider.setDark(value),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Consumer<AdminProvider>(
                    builder: (context, adminProvider, _) {
                      return Material(
                        color: colors.surface,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colors.border),
                        ),
                        child: SwitchListTile(
                          activeColor: colors.amber,
                          title: Text(
                            'Modo administrador (prueba)',
                            style: TextStyle(color: colors.textPrimary),
                          ),
                          subtitle: Text(
                            'Temporal — luego se reemplaza por permisos reales',
                            style: TextStyle(color: colors.textMuted),
                          ),
                          value: adminProvider.isAdminMode,
                          onChanged: (value) => adminProvider.toggle(value),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
