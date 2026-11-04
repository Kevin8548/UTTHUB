import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await context.read<UserProvider>().login(
<<<<<<< HEAD
      email: _emailController.text.trim(),
=======
      email: _emailController.text,
>>>>>>> 3e969c453fb40865bf3412f0927af8c6ecab8631
      password: _passwordController.text,
    );
    setState(() => _isSubmitting = false);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.emerald,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.school, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bienvenido de vuelta',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Ingresa con tu cuenta institucional',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: colors.textPrimary),
                  validator: (value) => (value == null || !value.contains('@'))
<<<<<<< HEAD
                      ? 'Correo institucional inválido'
=======
                      ? 'Correo inválido'
>>>>>>> 3e969c453fb40865bf3412f0927af8c6ecab8631
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Correo institucional',
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  style: TextStyle(color: colors.textPrimary),
                  validator: (value) => (value == null || value.isEmpty)
<<<<<<< HEAD
                      ? 'Ingresa tu contraseña'
=======
                      ? 'Campo requerido'
>>>>>>> 3e969c453fb40865bf3412f0927af8c6ecab8631
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: colors.textMuted,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text('Iniciar sesión'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
<<<<<<< HEAD
                    'Modo de prueba: cualquier correo institucional funciona',
=======
                    'Modo de prueba: cualquier correo y contraseña funcionan',
>>>>>>> 3e969c453fb40865bf3412f0927af8c6ecab8631
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 3e969c453fb40865bf3412f0927af8c6ecab8631
