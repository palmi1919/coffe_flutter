import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final int maxStock;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool compact;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.maxStock,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final canIncrement = quantity < maxStock;
    final canDecrement = quantity > 1;

    final size = compact ? 28.0 : 36.0;
    final iconSize = compact ? 16.0 : 20.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove_rounded,
            size: size,
            iconSize: iconSize,
            isEnabled: canDecrement,
            onTap: onDecrement,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14),
            child: Text(
              '$quantity',
              style: GoogleFonts.sora(
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add_rounded,
            size: size,
            iconSize: iconSize,
            isEnabled: canIncrement,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required double size,
    required double iconSize,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isEnabled ? AppTheme.surfaceWhite : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: iconSize,
            color: isEnabled ? AppTheme.textDark : AppTheme.textLight.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
