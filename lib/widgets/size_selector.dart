import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/product_size.dart';

class SizeSelector extends StatelessWidget {
  final List<ProductSize> sizes;
  final ProductSize selectedSize;
  final ValueChanged<ProductSize> onSizeSelected;

  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selecciona el tamaño',
              style: GoogleFonts.sora(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              selectedSize.descripcionCorta,
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.caramel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: sizes.map((size) {
            final isSelected = size.id == selectedSize.id;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: size == sizes.last ? 0 : 10,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSizeSelected(size),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.caramel.withOpacity(0.1)
                            : AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.caramel
                              : AppTheme.borderLight,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_cafe_rounded,
                            size: size.id == 'grande' ? 24 : (size.id == 'mediano' ? 20 : 18),
                            color: isSelected
                                ? AppTheme.caramel
                                : AppTheme.textMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            size.nombre,
                            style: GoogleFonts.sora(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.caramel
                                  : AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            size.precioAdicional > 0
                                ? '+${currencyFormat.format(size.precioAdicional)}'
                                : 'Base',
                            style: GoogleFonts.sora(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.caramel
                                  : AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
