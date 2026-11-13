import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../utils/constants.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/product_thumb.dart';

/// Pantalla "Agregar" (CREATE) o "Editar" (UPDATE) un producto.
class ProductFormView extends StatefulWidget {
  const ProductFormView({super.key, this.product});
  final Product? product;

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _quantity;
  late final TextEditingController _minStock;
  late final TextEditingController _description;
  late String _category;
  String? _imagePath;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final pr = widget.product;
    _name = TextEditingController(text: pr?.name ?? '');
    _price = TextEditingController(text: pr == null ? '' : '${pr.price}');
    _quantity = TextEditingController(text: pr == null ? '' : '${pr.quantity}');
    _minStock = TextEditingController(text: pr == null ? '5' : '${pr.minStock}');
    _description = TextEditingController(text: pr?.description ?? '');
    _category = AppConstants.categories.contains(pr?.category)
        ? pr!.category
        : AppConstants.categories.first;
    _imagePath = pr?.imagePath;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _quantity.dispose();
    _minStock.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker()
          .pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
      if (picked == null) return;
      // Copia la foto a la carpeta de la app para que no se pierda.
      final dir = await getApplicationDocumentsDirectory();
      final dest = p.join(
          dir.path, '${DateTime.now().millisecondsSinceEpoch}_${p.basename(picked.path)}');
      await File(picked.path).copy(dest);
      setState(() => _imagePath = dest);
    } catch (_) {
      if (mounted) showMessage(context, 'No se pudo cargar la imagen.', error: true);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await confirmDialog(
      context,
      title: _isEdit ? 'Guardar cambios' : 'Agregar producto',
      message: _isEdit
          ? '¿Deseas guardar los cambios de "${_name.text.trim()}"?'
          : '¿Deseas agregar "${_name.text.trim()}" al inventario?',
    );
    if (!ok || !mounted) return;

    final ctrl = context.read<ProductController>();
    final user = context.read<AuthController>().user!;
    setState(() => _saving = true);

    final old = widget.product;
    final product = Product(
      id: old?.id ?? ctrl.newId(),
      name: _name.text.trim(),
      description: _description.text.trim(),
      category: _category,
      price: double.parse(_price.text.trim().replaceAll(',', '.')),
      quantity: int.parse(_quantity.text.trim()),
      minStock: int.parse(_minStock.text.trim()),
      imagePath: _imagePath,
      imageUrl: old?.imageUrl,
      createdBy: old?.createdBy ?? user.uid,
      updatedAt: DateTime.now(),
    );

    try {
      final msg = await ctrl.save(product);
      if (!mounted) return;
      showMessage(context, msg);
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, 'No se pudo guardar el producto.', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = Product(
      id: 'preview',
      name: _name.text,
      description: '',
      category: _category,
      price: 0,
      quantity: 0,
      minStock: 0,
      createdBy: '',
      updatedAt: DateTime.now(),
      imagePath: _imagePath,
      imageUrl: widget.product?.imageUrl,
    );

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar producto' : 'Agregar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ProductThumb(product: preview, size: 130),
                      const CircleAvatar(
                        radius: 16,
                        child: Icon(Icons.camera_alt, size: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Toca para elegir una foto (opcional)'),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _name,
                  label: 'Nombre del producto',
                  icon: Icons.label_outline,
                  textInputAction: TextInputAction.next,
                  validator: Validators.productName,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _price,
                        label: 'Precio',
                        icon: Icons.attach_money,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        validator: Validators.price,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _quantity,
                        label: 'Existencias',
                        icon: Icons.numbers,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            Validators.integer(v, field: 'Las existencias'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _minStock,
                        label: 'Stock mínimo',
                        icon: Icons.warning_amber_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            Validators.integer(v, field: 'El stock mínimo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _category,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Categoría'),
                        items: AppConstants.categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v ?? _category),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _description,
                  label: 'Descripción',
                  icon: Icons.notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: _isEdit ? 'Guardar cambios' : 'Agregar',
                  icon: Icons.save_outlined,
                  loading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
