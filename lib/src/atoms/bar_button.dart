import 'package:flutter/material.dart';

import '../theme/game_palette.dart';

/// An icon on the bar, faded when there is nothing to do with it.
class BarButton extends StatelessWidget {
  const BarButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 21),
      style: IconButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor: palette.onFelt,
        disabledForegroundColor: palette.feltLight.withValues(alpha: .55),
        hoverColor: const Color(0x1AFFFFFF),
      ),
    );
  }
}
