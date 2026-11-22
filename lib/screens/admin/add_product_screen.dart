import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_theme.dart';
import '../../models/category.dart';
import '../../models/product_size.dart';
import '../../state/coffee_shop_scope.dart';

class LocalImageItem {
  final Uint8List bytes;
  final String name;

  LocalImageItem({required this.bytes, required this.name});
}

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

  ProductCategory? _selectedCategory;
  final List<LocalImageItem> _pickedImages = [];
  int _principalImageIndex = 0;
  bool _isSaving = false;

  // Tamaños seleccionados con sus precios adicionales
  final Map<int, bool> _sizesSelected = {};
  final Map<int, TextEditingController> _sizeExtraControllers = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    for (final c in _sizeExtraControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initSizes(List<ProductSize> masterSizes) {
    if (_sizesSelected.isEmpty && masterSizes.isNotEmpty) {
      for (final s in masterSizes) {
        // Por defecto activar chicos, medianos y grandes si son bebidas, o individual si es alimento
        final isDefault = s.id <= 3;
        _sizesSelected[s.id] = isDefault;
        double defaultExtra = 0.0;
        if (s.id == 2) defaultExtra = 12.0;
        if (s.id == 3) defaultExtra = 22.0;
        if (s.id == 5) defaultExtra = 35.0;
        _sizeExtraControllers[s.id] =
            TextEditingController(text: defaultExtra.toStringAsFixed(2));
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();
      final List<XFile> pickedList = await picker.pickMultiImage();
      if (pickedList.isNotEmpty) {
        for (final xfile in pickedList) {
          final bytes = await xfile.readAsBytes();
          _pickedImages.add(LocalImageItem(bytes: bytes, name: xfile.name));
        }
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudieron cargar las imágenes: $e'),
            backgroundColor: AppTheme.statusDanger,
          ),
        );
      }
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    final state = CoffeeShopScope.of(context);

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una categoría.'),
          backgroundColor: AppTheme.statusWarning,
        ),
      );
      return;
    }

    final double basePrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final int stock = int.tryParse(_stockController.text.trim()) ?? 0;

    // Construir lista de tamaños a vincular en producto_tamano
    final List<ProductSize> finalSizes = [];
    for (final s in state.masterSizes) {
      if (_sizesSelected[s.id] == true) {
        final extraText = _sizeExtraControllers[s.id]?.text.trim() ?? '0.00';
        final extraVal = double.tryParse(extraText) ?? 0.0;
        finalSizes.add(s.copyWith(precioAdicional: extraVal));
      }
    }

    if (finalSizes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un tamaño para el producto.'),
          backgroundColor: AppTheme.statusWarning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final bytesList = _pickedImages.map((img) => img.bytes).toList();

      await state.addProduct(
        nombre: _nameController.text.trim(),
        descripcion: _descController.text.trim(),
        precioBase: basePrice,
        categoriaId: _selectedCategory!.id,
        existencias: stock,
        tamanos: finalSizes,
        newImagesBytes: bytesList,
        principalImageIndex: _pickedImages.isNotEmpty ? _principalImageIndex : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Producto registrado con éxito!'),
          backgroundColor: AppTheme.statusSuccess,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error al guardar producto: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar el producto. Intenta de nuevo.'),
          backgroundColor: AppTheme.statusDanger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = CoffeeShopScope.of(context);
    final categories = state.categories;
    final masterSizes = state.masterSizes;

    _initSizes(masterSizes);
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Agregar nuevo café o producto',
          style: GoogleFonts.sora(
            fontSize: 17,
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
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
              children: [
                // SECCIÓN 1: SELECCIÓN Y SUBIDA DE IMÁGENES A SUPABASE STORAGE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.borderLight),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.photo_library_rounded,
                                color: AppTheme.caramel,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Imágenes del producto',
                                style: GoogleFonts.sora(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_pickedImages.length} fotos',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Selecciona una o más fotos desde tu equipo. Formatos soportados: JPG, PNG.',
                        style: GoogleFonts.sora(
                          fontSize: 11.5,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Vista previa de fotos seleccionadas
                      if (_pickedImages.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCream,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.borderLight,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: AppTheme.cinnamon,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No has seleccionado imágenes aún',
                                style: GoogleFonts.sora(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'El producto puede guardarse con o sin imágenes.',
                                style: GoogleFonts.sora(
                                  fontSize: 11,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 130,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _pickedImages.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, idx) {
                              final item = _pickedImages[idx];
                              final isPrincipal = (_principalImageIndex == idx);

                              return Stack(
                                children: [
                                  Container(
                                    width: 115,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isPrincipal
                                            ? AppTheme.caramel
                                            : AppTheme.borderLight,
                                        width: isPrincipal ? 2 : 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: Image.memory(
                                        item.bytes,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Botón eliminar imagen
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _pickedImages.removeAt(idx);
                                          if (_principalImageIndex >= _pickedImages.length) {
                                            _principalImageIndex = 0;
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.65),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Badge de principal / botón para marcar como principal
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _principalImageIndex = idx;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPrincipal
                                              ? AppTheme.caramel
                                              : Colors.black.withOpacity(0.65),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              isPrincipal
                                                  ? Icons.star_rounded
                                                  : Icons.star_border_rounded,
                                              color: Colors.white,
                                              size: 13,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isPrincipal ? 'Principal' : 'Elegir',
                                              style: GoogleFonts.sora(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                          label: Text(
                            'Seleccionar fotos desde el dispositivo',
                            style: GoogleFonts.sora(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.caramel,
                            side: const BorderSide(color: AppTheme.caramel),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // SECCIÓN 2: INFORMACIÓN GENERAL DEL PRODUCTO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.borderLight),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos del Producto',
                        style: GoogleFonts.sora(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Nombre
                      Text(
                        'Nombre del producto *',
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Ej. Capuchino de vainilla francesa',
                          filled: true,
                          fillColor: AppTheme.surfaceCream,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.borderLight),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Ingresa el nombre del producto';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // Categoría
                      Text(
                        'Categoría *',
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<ProductCategory>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surfaceCream,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.borderLight),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: categories.map((cat) {
                          return DropdownMenuItem<ProductCategory>(
                            value: cat,
                            child: Row(
                              children: [
                                Icon(cat.icono, size: 18, color: AppTheme.caramel),
                                const SizedBox(width: 8),
                                Text(
                                  cat.nombre,
                                  style: GoogleFonts.sora(fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedCategory = val);
                        },
                      ),

                      const SizedBox(height: 14),

                      // Descripción
                      Text(
                        'Descripción detallada',
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Ingredientes, método de preparación o notas de cata...',
                          filled: true,
                          fillColor: AppTheme.surfaceCream,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.borderLight),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Precio Base y Existencias
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Precio base (\$ MXN) *',
                                  style: GoogleFonts.sora(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _priceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    prefixText: '\$ ',
                                    hintText: '55.00',
                                    filled: true,
                                    fillColor: AppTheme.surfaceCream,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          const BorderSide(color: AppTheme.borderLight),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Requerido';
                                    }
                                    if (double.tryParse(val) == null) {
                                      return 'Inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Existencias iniciales *',
                                  style: GoogleFonts.sora(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _stockController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '20',
                                    filled: true,
                                    fillColor: AppTheme.surfaceCream,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          const BorderSide(color: AppTheme.borderLight),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Requerido';
                                    }
                                    if (int.tryParse(val) == null) {
                                      return 'Inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // SECCIÓN 3: CONFIGURACIÓN DE TAMAÑOS (producto_tamano)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.borderLight),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tamaños y Porciones',
                        style: GoogleFonts.sora(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Activa los tamaños que aplican a este producto e indica su precio adicional.',
                        style: GoogleFonts.sora(
                          fontSize: 11.5,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      const SizedBox(height: 14),

                      ...masterSizes.map((tamano) {
                        final isChecked = _sizesSelected[tamano.id] ?? false;
                        final controller = _sizeExtraControllers[tamano.id] ??
                            TextEditingController(text: '0.00');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isChecked
                                ? AppTheme.surfaceCream
                                : AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isChecked
                                  ? AppTheme.caramel.withOpacity(0.4)
                                  : AppTheme.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                activeColor: AppTheme.caramel,
                                onChanged: (val) {
                                  setState(() {
                                    _sizesSelected[tamano.id] = val ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tamano.nombre,
                                      style: GoogleFonts.sora(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    if (tamano.descripcionCorta.isNotEmpty)
                                      Text(
                                        tamano.descripcionCorta,
                                        style: GoogleFonts.sora(
                                          fontSize: 11,
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isChecked) ...[
                                Text(
                                  '+ \$',
                                  style: GoogleFonts.sora(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.caramel,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 75,
                                  height: 38,
                                  child: TextField(
                                    controller: controller,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide:
                                            const BorderSide(color: AppTheme.borderLight),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Botón inferior flotante de guardar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                border: const Border(top: BorderSide(color: AppTheme.borderLight)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.caramel,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Guardando producto...'),
                          ],
                        )
                      : Text(
                          'Guardar Producto',
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
