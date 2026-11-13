import 'dart:io';

import 'package:flutter/material.dart';

import '../models/product.dart';

/// Miniatura del producto: foto local, foto remota o icono por defecto.
class ProductThumb extends StatelessWidget {
  const ProductThumb({super.key, required this.product, this.size = 56});

  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.inventory_2_outlined, size: size * 0.55);
    Widget child = fallback;

    final path = product.imagePath;
    if (path != null && File(path).existsSync()) {
      child = Image.file(File(path), fit: BoxFit.cover);
    } else if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      child = Image.network(
        product.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size,
        height: size,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: child,
      ),
    );
  }
}
