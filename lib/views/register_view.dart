import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_theme.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';

/// Pantalla "Crear cuenta". Toda cuenta nueva nace con el rol Usuario.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<AuthController>().register(
          username: _username.text,
          email: _email.text,
          password: _password.text,
        );
    if (!mounted) return;
    if (error != null) {
      showMessage(context, error, error: true);
      return;
    }
    showMessage(context, 'Cuenta creada correctamente. ¡Bienvenido!');
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthController>().busy;
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.person_add_alt_1,
                        size: 72, color: AppTheme.primary),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _username,
                      label: 'Nombre de usuario',
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: Validators.username,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _email,
                      label: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _password,
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      obscure: true,
                      textInputAction: TextInputAction.next,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _confirm,
                      label: 'Confirmar contraseña',
                      icon: Icons.lock_reset,
                      obscure: true,
                      validator: (v) =>
                          v != _password.text ? 'Las contraseñas no coinciden' : null,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Registrarse',
                      icon: Icons.person_add,
                      loading: busy,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
