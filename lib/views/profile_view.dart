import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';

/// Pantalla "Perfil": consulta y actualiza los datos del usuario.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username;

  @override
  void initState() {
    super.initState();
    _username =
        TextEditingController(text: context.read<AuthController>().user!.username);
  }

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final error =
        await context.read<AuthController>().updateUsername(_username.text);
    if (!mounted) return;
    showMessage(context, error ?? 'Perfil actualizado.', error: error != null);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppTheme.primary,
                child: Text(
                  user.username.isEmpty ? '?' : user.username[0].toUpperCase(),
                  style: const TextStyle(fontSize: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Chip(
                avatar: Icon(
                  user.isAdmin ? Icons.shield : Icons.person,
                  size: 18,
                ),
                label: Text(AppRoles.label(user.role)),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _username,
                label: 'Nombre de usuario',
                icon: Icons.person_outline,
                validator: Validators.username,
              ),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: user.email,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Guardar cambios',
                icon: Icons.save_outlined,
                loading: auth.busy,
                onPressed: _save,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  final error = await context
                      .read<AuthController>()
                      .recoverPassword(user.email);
                  if (!context.mounted) return;
                  showMessage(
                    context,
                    error ?? 'Te enviamos un correo para cambiar tu contraseña.',
                    error: error != null,
                  );
                },
                icon: const Icon(Icons.lock_reset),
                label: const Text('Cambiar contraseña por correo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
