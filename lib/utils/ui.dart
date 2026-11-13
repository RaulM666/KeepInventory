import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Muestra un mensaje breve (SnackBar) de éxito o error.
void showMessage(BuildContext context, String text, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? AppTheme.danger : AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

/// Diálogo de confirmación. Devuelve true si el usuario confirma.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Aceptar',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}

String money(double v) => '\$${v.toStringAsFixed(2)}';
