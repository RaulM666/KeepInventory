import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../models/app_user.dart';
import '../repositories/user_repository.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../utils/ui.dart';

/// Módulo "Usuarios" (solo Administrador): lista usuarios y cambia sus roles.
class UsersAdminView extends StatefulWidget {
  const UsersAdminView({super.key});

  @override
  State<UsersAdminView> createState() => _UsersAdminViewState();
}

class _UsersAdminViewState extends State<UsersAdminView> {
  final _repo = UserRepository(FirestoreService());
  List<AppUser> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _repo.listUsers().timeout(AppConstants.remoteTimeout);
      if (mounted) setState(() => _users = list);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo cargar la lista. Revisa tu conexión.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeRole(AppUser u, String role) async {
    if (role == u.role) return;
    final ok = await confirmDialog(
      context,
      title: 'Cambiar rol',
      message: '¿Cambiar el rol de ${u.username} a ${AppRoles.label(role)}?',
    );
    if (!ok || !mounted) return;
    try {
      await _repo.setRole(u.uid, role);
      if (!mounted) return;
      showMessage(context, 'Rol actualizado.');
      _load();
    } catch (_) {
      if (mounted) showMessage(context, 'No se pudo cambiar el rol.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthController>().user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    itemBuilder: (context, i) {
                      final u = _users[i];
                      final isMe = u.uid == me.uid;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(u.username.isEmpty
                                ? '?'
                                : u.username[0].toUpperCase()),
                          ),
                          title: Text(isMe ? '${u.username} (tú)' : u.username),
                          subtitle: Text(u.email),
                          trailing: isMe
                              ? Chip(label: Text(AppRoles.label(u.role)))
                              : DropdownButton<String>(
                                  value: u.role,
                                  underline: const SizedBox.shrink(),
                                  items: [AppRoles.user, AppRoles.admin]
                                      .map((r) => DropdownMenuItem(
                                            value: r,
                                            child: Text(AppRoles.label(r)),
                                          ))
                                      .toList(),
                                  onChanged: (r) {
                                    if (r != null) _changeRole(u, r);
                                  },
                                ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
