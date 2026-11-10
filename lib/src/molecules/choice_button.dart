import 'package:flutter/material.dart';

import '../theme/game_palette.dart';

/// A choice on the bar, such as the difficulty: the current one with an
/// arrow, or only an icon when space is short, and a menu with all of them.
class ChoiceButton<T> extends StatelessWidget {
  const ChoiceButton({
    super.key,
    required this.tooltip,
    required this.current,
    required this.choices,
    required this.label,
    required this.onSelected,
    this.menuLabel,
    this.icon = Icons.tune_rounded,
    this.iconOnly = false,
  });

  final String tooltip;
  final T current;
  final List<T> choices;

  /// The short name, shown on the bar.
  final String Function(T choice) label;

  /// The longer name, in the menu. Without one, the short name.
  final String Function(T choice)? menuLabel;
  final ValueChanged<T> onSelected;
  final IconData icon;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return PopupMenuButton<T>(
      tooltip: tooltip,
      initialValue: current,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final choice in choices)
          PopupMenuItem(
            value: choice,
            child: Text((menuLabel ?? label)(choice)),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconOnly)
              Icon(icon, size: 21, color: palette.onFelt)
            else
              Text(
                label(current),
                style: TextStyle(
                  color: palette.onFelt,
                  fontWeight: FontWeight.w600,
                ),
              ),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 20,
              color: palette.onFeltMuted,
            ),
          ],
        ),
      ),
    );
  }
}
