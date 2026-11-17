import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/product_size.dart';
import '../../services/seed_data.dart';
import '../../state/coffee_shop_scope.dart';
import '../../widgets/confirm_dialog.dart';

class EditProductsScreen extends StatefulWidget {
  const EditProductsScreen({super.key});

  @override
  State<EditProductsScreen> createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  String _filterQuery = '';

  void _openEditModal(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _EditProductSheet(product: product);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = CoffeeShopScope.of(context);
    final allProducts = state.allProducts;

    final filtered = allProducts.where((p) {
      if (_filterQuery.trim().isEmpty) return true;
      final q = _filterQuery.toLowerCase().trim();
      return p.nombre.toLowerCase().contains(q) ||
          p.categoria.nombre.toLowerCase().contains(q);
    }).toList();

    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Catálogo de productos',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Barra de filtro de administrador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              onChanged: (val) => setState(() => _filterQuery = val),
              decoration: InputDecoration(
                hintText: 'Filtrar por nombre o categoría...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.caramel),
                filled: true,
                fillColor: AppTheme.surfaceWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Conteo y estatus
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} productos registrados',
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMedium,
                  ),
                ),
                Text(
                  'Toca para editar o dar de baja',
                  style: GoogleFonts.sora(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Lista de productos
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = filtered[index];
                final isInactive = !product.estaActivo;

                return Container(
                  decoration: BoxDecoration(
                    color: isInactive
                        ? AppTheme.surfaceCream.withOpacity(0.6)
                        : AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isInactive
                          ? AppTheme.statusDanger.withOpacity(0.3)
                          : AppTheme.borderLight,
                    ),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CachedNetworkImage(
                              imageUrl: product.imagenUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                color: AppTheme.surfaceCream,
                                child: const Icon(
                                  Icons.coffee_rounded,
                                  color: AppTheme.cinnamon,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isInactive)
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.visibility_off_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sora(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isInactive
                                  ? AppTheme.textLight
                                  : AppTheme.textDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isInactive
                                ? AppTheme.statusDanger.withOpacity(0.12)
                                : AppTheme.statusSuccess.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isInactive ? 'Inactivo' : 'Activo',
                            style: GoogleFonts.sora(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isInactive
                                  ? AppTheme.statusDanger
                                  : AppTheme.statusSuccess,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${product.categoria.nombre} • ${currencyFormat.format(product.precioBase)}',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            color: AppTheme.textMedium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Existencias: ${product.existencias} unidades',
                          style: GoogleFonts.sora(
                            fontSize: 11,
                            color: product.existencias == 0
                                ? AppTheme.statusDanger
                                : AppTheme.textLight,
                            fontWeight: product.existencias == 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de cambio rápido de estatus
                        IconButton(
                          tooltip: isInactive
                              ? 'Reactivar producto'
                              : 'Dar de baja producto',
                          icon: Icon(
                            isInactive
                                ? Icons.toggle_off_rounded
                                : Icons.toggle_on_rounded,
                            size: 32,
                            color: isInactive
                                ? AppTheme.textLight
                                : AppTheme.statusSuccess,
                          ),
                          onPressed: () async {
                            final confirm = await ConfirmDialog.show(
                              context: context,
                              title: isInactive
                                  ? '¿Reactivar producto?'
                                  : '¿Dar de baja producto?',
                              message: isInactive
                                  ? 'El producto volverá a mostrarse en el menú del cliente.'
                                  : 'El producto se ocultará del menú del cliente sin eliminarse de la base de datos.',
                              confirmText:
                                  isInactive ? 'Reactivar' : 'Dar de baja',
                              confirmColor: isInactive
                                  ? AppTheme.statusSuccess
                                  : AppTheme.statusDanger,
                              icon: isInactive
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            );

                            if (confirm) {
                              await state.toggleProductStatus(product.id);
                            }
                          },
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.textLight,
                        ),
                      ],
                    ),
                    onTap: () => _openEditModal(context, product),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProductSheet extends StatefulWidget {
  final Product product;

  const _EditProductSheet({required this.product});

  @override
  State<_EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends State<_EditProductSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;

  late ProductCategory _selectedCategory;
  late bool _estaActivo;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.nombre);
    _descController = TextEditingController(text: widget.product.descripcion);
    _priceController =
        TextEditingController(text: widget.product.precioBase.toStringAsFixed(2));
    _stockController =
        TextEditingController(text: widget.product.existencias.toString());
    _imageUrlController =
        TextEditingController(text: widget.product.imagenUrl);
    _selectedCategory = widget.product.categoria;
    _estaActivo = widget.product.estaActivo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _openImagePicker() {
    final presets = SeedData.presetImages();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elige una fotografía de la galería',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 260,
                  child: GridView.builder(
                    itemCount: presets.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, idx) {
                      final item = presets[idx];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _imageUrlController.text = item['url']!;
                          });
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: item['url']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    // Confirmación previa antes de modificaciones importantes
    final confirm = await ConfirmDialog.show(
      context: context,
      title: '¿Guardar modificaciones?',
      message:
          'Se actualizarán los datos de "${_nameController.text.trim()}" en la base de datos local.',
      confirmText: 'Guardar cambios',
      confirmColor: AppTheme.caramel,
      icon: Icons.edit_calendar_rounded,
    );

    if (confirm && mounted) {
      final updated = widget.product.copyWith(
        nombre: _nameController.text.trim(),
        descripcion: _descController.text.trim(),
        precioBase: double.parse(_priceController.text.trim()),
        categoria: _selectedCategory,
        existencias: int.parse(_stockController.text.trim()),
        imagenUrl: _imageUrlController.text.trim(),
        estaActivo: _estaActivo,
      );

      final state = CoffeeShopScope.of(context);
      await state.updateProduct(updated);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Producto "${updated.nombre}" actualizado con éxito.',
              style: GoogleFonts.sora(fontSize: 13),
            ),
            backgroundColor: AppTheme.statusSuccess,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Editar producto',
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Switch de estatus (Dar de baja sin eliminar)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _estaActivo
                        ? AppTheme.statusSuccess.withOpacity(0.08)
                        : AppTheme.statusDanger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _estaActivo
                          ? AppTheme.statusSuccess.withOpacity(0.3)
                          : AppTheme.statusDanger.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _estaActivo
                                ? 'Estatus: Activo (Visible en menú)'
                                : 'Estatus: Dado de baja (Oculto)',
                            style: GoogleFonts.sora(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _estaActivo
                                  ? AppTheme.statusSuccess
                                  : AppTheme.statusDanger,
                            ),
                          ),
                          Text(
                            'Conservar registro en base de datos',
                            style: GoogleFonts.sora(
                              fontSize: 11,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _estaActivo,
                        activeColor: AppTheme.statusSuccess,
                        inactiveThumbColor: AppTheme.statusDanger,
                        onChanged: (val) {
                          setState(() => _estaActivo = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Previsualización de imagen
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: CachedNetworkImage(
                          imageUrl: _imageUrlController.text.trim(),
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.surfaceCream,
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openImagePicker,
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: const Text('Cambiar imagen'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nombre
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                    prefixIcon: Icon(Icons.coffee_rounded, color: AppTheme.caramel),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Requerido.' : null,
                ),
                const SizedBox(height: 14),

                // Descripción
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon:
                        Icon(Icons.description_outlined, color: AppTheme.caramel),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Requerido.' : null,
                ),
                const SizedBox(height: 14),

                // Categoría
                DropdownButtonFormField<ProductCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon:
                        Icon(Icons.category_outlined, color: AppTheme.caramel),
                  ),
                  items: ProductCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.nombre, style: GoogleFonts.sora(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Precio y existencias
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Precio base (\$)',
                          prefixIcon: Icon(
                            Icons.attach_money_rounded,
                            color: AppTheme.caramel,
                          ),
                        ),
                        validator: (val) {
                          final p = double.tryParse(val ?? '');
                          if (p == null || p <= 0) return 'Inválido.';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Existencias',
                          prefixIcon: Icon(
                            Icons.inventory_2_outlined,
                            color: AppTheme.caramel,
                          ),
                        ),
                        validator: (val) {
                          final s = int.tryParse(val ?? '');
                          if (s == null || s < 0) return 'Inválido.';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Botón Guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.caramel,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded, color: Colors.white),
                    label: Text(
                      'Guardar modificaciones',
                      style: GoogleFonts.sora(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
