import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/app_theme.dart';
import '../utils/ui.dart';
import 'product_thumb.dart';

/// Tarjeta de un producto en la lista de inventario.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback? onDelete; // null si el rol no puede eliminar

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ProductThumb(product: product),
        title: Text(product.name,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${money(product.price)}  ·  ${product.category}\n'
          'Existencias: ${product.quantity}'
          '${product.lowStock ? '  ⚠ Stock bajo' : ''}',
          style: TextStyle(
            color: product.lowStock ? AppTheme.danger : null,
          ),
        ),
        isThreeLine: true,
        onTap: onEdit,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
