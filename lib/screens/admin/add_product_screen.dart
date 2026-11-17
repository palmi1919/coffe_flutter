import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/product_size.dart';
import '../../services/seed_data.dart';
import '../../state/coffee_shop_scope.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '15');
  final _imageUrlController = TextEditingController();

  ProductCategory _selectedCategory = ProductCategory.bebidasCalientes;

  // Opciones de tamaños seleccionadas
  bool _includeChico = true;
  bool _includeMediano = true;
  bool _includeGrande = true;

  final _chicoExtraController = TextEditingController(text: '0.00');
  final _medianoExtraController = TextEditingController(text: '12.00');
  final _grandeExtraController = TextEditingController(text: '22.00');

  @override
  void initState() {
    super.initState();
    // Imagen predeterminada inicial
    _imageUrlController.text = SeedData.presetImages().first['url']!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _chicoExtraController.dispose();
    _medianoExtraController.dispose();
    _grandeExtraController.dispose();
    super.dispose();
  }

  void _openPresetImagePicker() {
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
                  'Selecciona una imagen de la galería',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Armar lista de tamaños seleccionados
    final List<ProductSize> sizes = [];
    if (_includeChico) {
      sizes.add(
        ProductSize(
          id: 'chico',
          nombre: 'Chico',
          descripcionCorta: '8 oz / Porción estándar',
          precioAdicional:
              double.tryParse(_chicoExtraController.text.trim()) ?? 0.0,
        ),
      );
    }
    if (_includeMediano) {
      sizes.add(
        ProductSize(
          id: 'mediano',
          nombre: 'Mediano',
          descripcionCorta: '12 oz / Porción grande',
          precioAdicional:
              double.tryParse(_medianoExtraController.text.trim()) ?? 12.0,
        ),
      );
    }
    if (_includeGrande) {
      sizes.add(
        ProductSize(
          id: 'grande',
          nombre: 'Grande',
          descripcionCorta: '16 oz / Porción jumbo',
          precioAdicional:
              double.tryParse(_grandeExtraController.text.trim()) ?? 22.0,
        ),
      );
    }

    if (sizes.isEmpty) {
      sizes.add(
        const ProductSize(
          id: 'estandar',
          nombre: 'Estándar',
          descripcionCorta: '1 unidad',
          precioAdicional: 0.0,
        ),
      );
    }

    final newProduct = Product(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      nombre: _nameController.text.trim(),
      descripcion: _descController.text.trim(),
      precioBase: double.parse(_priceController.text.trim()),
      categoria: _selectedCategory,
      tamanos: sizes,
      existencias: int.parse(_stockController.text.trim()),
      imagenUrl: _imageUrlController.text.trim(),
      estaActivo: true,
    );

    final state = CoffeeShopScope.of(context);
    await state.addProduct(newProduct);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Producto "${newProduct.nombre}" registrado exitosamente!',
            style: GoogleFonts.sora(fontSize: 13),
          ),
          backgroundColor: AppTheme.statusSuccess,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Agregar producto',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Previsualización y selector de fotografía
              Text(
                'Fotografía del producto',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 190,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: AppTheme.softShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_imageUrlController.text.trim().isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: _imageUrlController.text.trim(),
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 48,
                              color: AppTheme.textLight,
                            ),
                          ),
                        )
                      else
                        const Center(
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: AppTheme.cinnamon,
                          ),
                        ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: ElevatedButton.icon(
                          onPressed: _openPresetImagePicker,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.espresso.withOpacity(0.85),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(
                            Icons.photo_library_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Elegir foto',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Campo de URL personalizado
              TextFormField(
                controller: _imageUrlController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'URL de la fotografía',
                  hintText: 'https://ejemplo.com/cafe.jpg',
                  prefixIcon: Icon(
                    Icons.link_rounded,
                    color: AppTheme.caramel,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingresa una URL o selecciona una foto de la galería.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Nombre del producto
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  hintText: 'Ej. Capuchino vainilla',
                  prefixIcon: Icon(
                    Icons.coffee_rounded,
                    color: AppTheme.caramel,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'El nombre del producto es obligatorio.';
                  }
                  if (val.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción del producto',
                  hintText:
                      'Detalla los ingredientes, sabor y preparación...',
                  prefixIcon: Icon(
                    Icons.description_outlined,
                    color: AppTheme.caramel,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'La descripción es obligatoria.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Categoría
              DropdownButtonFormField<ProductCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(
                    Icons.category_outlined,
                    color: AppTheme.caramel,
                  ),
                ),
                items: ProductCategory.values.map((cat) {
                  return DropdownMenuItem<ProductCategory>(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(cat.icono, size: 18, color: AppTheme.caramel),
                        const SizedBox(width: 10),
                        Text(
                          cat.nombre,
                          style: GoogleFonts.sora(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Fila con Precio base y Existencias
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
                        hintText: '0.00',
                        prefixIcon: Icon(
                          Icons.attach_money_rounded,
                          color: AppTheme.caramel,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingresa un precio.';
                        }
                        final parsed = double.tryParse(val.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Precio inválido.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Existencias (stock)',
                        hintText: '0',
                        prefixIcon: Icon(
                          Icons.inventory_2_outlined,
                          color: AppTheme.caramel,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingresa existencias.';
                        }
                        final parsed = int.tryParse(val.trim());
                        if (parsed == null || parsed < 0) {
                          return 'Stock inválido.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tamaños disponibles
              Text(
                'Tamaños disponibles y costos adicionales',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),

              // Tamaño Chico
              _buildSizeOptionTile(
                name: 'Chico (8 oz / Estándar)',
                enabled: _includeChico,
                controller: _chicoExtraController,
                onChanged: (val) => setState(() => _includeChico = val),
              ),
              const SizedBox(height: 8),

              // Tamaño Mediano
              _buildSizeOptionTile(
                name: 'Mediano (12 oz)',
                enabled: _includeMediano,
                controller: _medianoExtraController,
                onChanged: (val) => setState(() => _includeMediano = val),
              ),
              const SizedBox(height: 8),

              // Tamaño Grande
              _buildSizeOptionTile(
                name: 'Grande (16 oz)',
                enabled: _includeGrande,
                controller: _grandeExtraController,
                onChanged: (val) => setState(() => _includeGrande = val),
              ),
              const SizedBox(height: 28),

              // Botón Guardar producto
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.caramel,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.save_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Guardar nuevo producto',
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
    );
  }

  Widget _buildSizeOptionTile({
    required String name,
    required bool enabled,
    required TextEditingController controller,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled ? AppTheme.caramel : AppTheme.borderLight,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: enabled,
            activeColor: AppTheme.caramel,
            onChanged: (val) => onChanged(val ?? false),
          ),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: enabled ? FontWeight.w600 : FontWeight.w400,
                color: enabled ? AppTheme.textDark : AppTheme.textLight,
              ),
            ),
          ),
          if (enabled) ...[
            Text(
              '+ \$',
              style: GoogleFonts.sora(
                fontSize: 13,
                color: AppTheme.caramel,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 65,
              child: TextFormField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
