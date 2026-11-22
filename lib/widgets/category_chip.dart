import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../models/category.dart';

class CategorySelectorBar extends StatelessWidget {
  final ProductCategory? selectedCategory;
  final List<ProductCategory> categories;
  final ValueChanged<ProductCategory?> onSelected;

  const CategorySelectorBar({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildChip(
            title: 'Todas',
            icon: Icons.grid_view_rounded,
            isSelected: selectedCategory == null,
            onTap: () => onSelected(null),
          ),
          ...categories.map((cat) {
            final isSelected = selectedCategory?.id == cat.id;
            return _buildChip(
              title: cat.nombre,
              icon: cat.icono,
              isSelected: isSelected,
              onTap: () => onSelected(cat),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryCoffee : AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppTheme.primaryCoffee : AppTheme.borderLight,
                width: 1,
              ),
              boxShadow: isSelected ? AppTheme.softShadow : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? AppTheme.caramelLight : AppTheme.textMedium,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textDark,
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
