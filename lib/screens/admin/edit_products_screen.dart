import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/product_image.dart';
import '../../models/product_size.dart';
import '../../state/coffee_shop_scope.dart';
import '../../widgets/confirm_dialog.dart';
import 'add_product_screen.dart';

class EditProductsScreen extends StatefulWidget {
  final bool isEmbedded;
  const EditProductsScreen({super.key, this.isEmbedded = false});

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
      final catMatch = p.categoria?.nombre.toLowerCase().contains(q) ?? false;
      return p.nombre.toLowerCase().contains(q) || catMatch;
    }).toList();

    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    final bodyContent = Column(
      children: [
        // Barra de filtro
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
                '${filtered.length} productos en Supabase',
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
          child: RefreshIndicator(
            onRefresh: () => state.loadData(),
            color: AppTheme.caramel,
            child: filtered.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Text(
                        'No hay productos registrados en este filtro.',
                        style: GoogleFonts.sora(fontSize: 13, color: AppTheme.textLight),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      final isInactive = !product.estaActivo;
                      final mainImg = product.primaryImageUrl;

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
                                  child: mainImg.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: mainImg,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => Container(
                                            color: AppTheme.surfaceCream,
                                            child: const Icon(
                                              Icons.coffee_rounded,
                                              color: AppTheme.cinnamon,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: AppTheme.surfaceCream,
                                          child: const Icon(
                                            Icons.coffee_rounded,
                                            color: AppTheme.cinnamon,
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
                                '${product.categoria?.nombre ?? "Café"} • ${currencyFormat.format(product.precioBase)}',
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
                              IconButton(
                                icon: Icon(
                                  isInactive
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: isInactive
                                      ? AppTheme.statusDanger
                                      : AppTheme.statusSuccess,
                                ),
                                tooltip: isInactive ? 'Reactivar' : 'Dar de baja',
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
        ),
      ],
    );

    if (widget.isEmbedded) {
      return bodyContent;
    }

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
      body: bodyContent,
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

  ProductCategory? _selectedCategory;
  late bool _estaActivo;

  // Manejo de imágenes existentes y nuevas
  late List<ProductImage> _existingImages;
  final List<LocalImageItem> _newImages = [];
  final List<int> _deleteImageIds = [];
  int? _principalExistingImageId;
  int? _principalNewImageIndex;
  bool _isSaving = false;

  // Tamaños seleccionados
  final Map<int, bool> _sizesSelected = {};
  final Map<int, TextEditingController> _sizeExtraControllers = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.nombre);
    _descController = TextEditingController(text: widget.product.descripcion);
    _priceController =
        TextEditingController(text: widget.product.precioBase.toStringAsFixed(2));
    _stockController =
        TextEditingController(text: widget.product.existencias.toString());
    _selectedCategory = widget.product.categoria;
    _estaActivo = widget.product.estaActivo;

    _existingImages = List.from(widget.product.imagenes);
    final principalImg = _existingImages.firstWhere(
      (img) => img.esPrincipal,
      orElse: () => _existingImages.isNotEmpty
          ? _existingImages.first
          : const ProductImage(id: -1, fkProducto: 0, url: ''),
    );
    _principalExistingImageId = principalImg.id != -1 ? principalImg.id : null;
  }

  void _initSizes(List<ProductSize> masterSizes) {
    if (_sizesSelected.isEmpty && masterSizes.isNotEmpty) {
      for (final s in masterSizes) {
        final existingSize = widget.product.tamanos.firstWhere(
          (ts) => ts.id == s.id,
          orElse: () => const ProductSize(id: -1, nombre: '', descripcionCorta: ''),
        );

        final isPresent = existingSize.id != -1;
        _sizesSelected[s.id] = isPresent;
        _sizeExtraControllers[s.id] = TextEditingController(
          text: isPresent
              ? existingSize.precioAdicional.toStringAsFixed(2)
              : (s.id == 2 ? '12.00' : (s.id == 3 ? '22.00' : '0.00')),
        );
      }
    }
  }

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

  Future<void> _pickNewImages() async {
    try {
      final picker = ImagePicker();
      final List<XFile> pickedList = await picker.pickMultiImage();
      if (pickedList.isNotEmpty) {
        for (final xfile in pickedList) {
          final bytes = await xfile.readAsBytes();
          _newImages.add(LocalImageItem(bytes: bytes, name: xfile.name));
        }
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar imágenes: $e'),
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
          content: Text('Selecciona una categoría válida.'),
          backgroundColor: AppTheme.statusWarning,
        ),
      );
      return;
    }

    final double basePrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final int stock = int.tryParse(_stockController.text.trim()) ?? 0;

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
          content: Text('Debes seleccionar al menos un tamaño para el producto.'),
          backgroundColor: AppTheme.statusWarning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newBytesList = _newImages.map((img) => img.bytes).toList();

      await state.updateProduct(
        productId: widget.product.id,
        nombre: _nameController.text.trim(),
        descripcion: _descController.text.trim(),
        precioBase: basePrice,
        categoriaId: _selectedCategory!.id,
        existencias: stock,
        estaActivo: _estaActivo,
        tamanos: finalSizes,
        existingImages: _existingImages,
        newImagesBytes: newBytesList,
        principalExistingImageId: _principalExistingImageId,
        principalNewImageIndex: _principalNewImageIndex,
        deleteImageIds: _deleteImageIds,
      );

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Producto actualizado correctamente en Supabase!'),
          backgroundColor: AppTheme.statusSuccess,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar en Supabase: $e'),
          backgroundColor: AppTheme.statusDanger,
        ),
      );
    }
  }

  Future<void> _onDeleteProduct(BuildContext context) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      title: '¿Eliminar producto?',
      message:
          '¿Estás seguro de que deseas eliminar permanentemente este producto de Supabase? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      confirmColor: AppTheme.statusDanger,
      icon: Icons.delete_forever_rounded,
    );

    if (confirm && mounted) {
      final state = CoffeeShopScope.of(context);
      try {
        await state.deleteProduct(widget.product.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado exitosamente.'),
              backgroundColor: AppTheme.statusSuccess,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar producto: $e'),
              backgroundColor: AppTheme.statusDanger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = CoffeeShopScope.of(context);
    final categories = state.categories;
    final masterSizes = state.masterSizes;

    _initSizes(masterSizes);

    if (_selectedCategory == null && categories.isNotEmpty) {
      final match = categories.firstWhere(
        (c) => c.id == widget.product.fkCategoria,
        orElse: () => categories.first,
      );
      _selectedCategory = match;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Cabecera del modal
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editar Producto #${widget.product.id}',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.statusDanger,
                        ),
                        tooltip: 'Eliminar producto',
                        onPressed: () => _onDeleteProduct(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderLight),

            // Formulario
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    // GESTIÓN DE IMÁGENES
                    Text(
                      'Imágenes del Producto',
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toca "Principal" para elegir la foto de portada. Usa la cruz para eliminar fotos.',
                      style: GoogleFonts.sora(fontSize: 11.5, color: AppTheme.textMedium),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 130,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Imágenes existentes en Supabase Storage
                          ..._existingImages.map((img) {
                            final isMarkedDeleted = _deleteImageIds.contains(img.id);
                            if (isMarkedDeleted) return const SizedBox.shrink();

                            final isPrincipal = (_principalExistingImageId == img.id &&
                                _principalNewImageIndex == null);

                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Stack(
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
                                      child: CachedNetworkImage(
                                        imageUrl: img.url,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => Container(
                                          color: AppTheme.surfaceCream,
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Quitar foto existente
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (img.id != null) {
                                            _deleteImageIds.add(img.id!);
                                          }
                                          if (_principalExistingImageId == img.id) {
                                            _principalExistingImageId = null;
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
                                  // Botón principal
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _principalExistingImageId = img.id;
                                          _principalNewImageIndex = null;
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
                              ),
                            );
                          }),

                          // Imágenes nuevas seleccionadas localmente
                          ..._newImages.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            final isPrincipal = (_principalNewImageIndex == idx);

                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Stack(
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
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _newImages.removeAt(idx);
                                          if (_principalNewImageIndex == idx) {
                                            _principalNewImageIndex = null;
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
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _principalNewImageIndex = idx;
                                          _principalExistingImageId = null;
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
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickNewImages,
                        icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                        label: Text(
                          'Agregar más fotos desde el dispositivo',
                          style: GoogleFonts.sora(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.caramel,
                          side: const BorderSide(color: AppTheme.caramel),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppTheme.borderLight),
                    const SizedBox(height: 16),

                    // NOMBRE
                    Text('Nombre del producto', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceCream,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                    ),

                    const SizedBox(height: 14),

                    // CATEGORÍA
                    Text('Categoría', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<ProductCategory>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceCream,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem<ProductCategory>(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(cat.icono, size: 16, color: AppTheme.caramel),
                              const SizedBox(width: 8),
                              Text(cat.nombre, style: GoogleFonts.sora(fontSize: 13)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),

                    const SizedBox(height: 14),

                    // DESCRIPCIÓN
                    Text('Descripción', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceCream,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // PRECIO Y EXISTENCIAS
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Precio base (\$ MXN)', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  filled: true,
                                  fillColor: AppTheme.surfaceCream,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (val) => val == null || double.tryParse(val) == null ? 'Inválido' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Existencias', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _stockController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppTheme.surfaceCream,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (val) => val == null || int.tryParse(val) == null ? 'Inválido' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // SWITCH ACTIVO / INACTIVO
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Estatus en Menú (Activo)',
                        style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _estaActivo ? 'Visible para clientes' : 'Oculto para clientes',
                        style: GoogleFonts.sora(fontSize: 11, color: AppTheme.textLight),
                      ),
                      value: _estaActivo,
                      activeColor: AppTheme.caramel,
                      onChanged: (val) => setState(() => _estaActivo = val),
                    ),

                    const SizedBox(height: 14),

                    // TAMAÑOS
                    Text('Tamaños aplicables', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...masterSizes.map((tamano) {
                      final isChecked = _sizesSelected[tamano.id] ?? false;
                      final controller = _sizeExtraControllers[tamano.id] ??
                          TextEditingController(text: '0.00');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isChecked ? AppTheme.surfaceCream : AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isChecked ? AppTheme.caramel.withOpacity(0.4) : AppTheme.borderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              activeColor: AppTheme.caramel,
                              onChanged: (val) => setState(() => _sizesSelected[tamano.id] = val ?? false),
                            ),
                            Expanded(
                              child: Text(
                                '${tamano.nombre} (${tamano.descripcionCorta})',
                                style: GoogleFonts.sora(fontSize: 12.5),
                              ),
                            ),
                            if (isChecked) ...[
                              Text('+ \$', style: GoogleFonts.sora(fontSize: 12, color: AppTheme.caramel)),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 70,
                                height: 36,
                                child: TextField(
                                  controller: controller,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.all(8),
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
            ),

            // Botón guardar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.borderLight)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.caramel,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Actualizando en Supabase...'),
                          ],
                        )
                      : Text(
                          'Actualizar Producto en Supabase',
                          style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
