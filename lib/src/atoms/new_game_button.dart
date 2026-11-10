import 'package:flutter/material.dart';

import '../l10n.dart';
import '../platform.dart';
import '../theme/game_palette.dart';

/// The cream button that starts a new game, only the dice when space is
/// short.
class NewGameButton extends StatelessWidget {
  const NewGameButton({
    super.key,
    required this.iconOnly,
    required this.onPressed,
  });

  final bool iconOnly;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = context.gamesUi.newGame;
    final style = FilledButton.styleFrom(
      backgroundColor: palette.cream,
      foregroundColor: palette.barBottom,
      padding: EdgeInsets.symmetric(horizontal: iconOnly ? 10 : 14),
      minimumSize: const Size(40, 38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    );
    const icon = Icon(Icons.casino_outlined, size: 19);
    if (iconOnly) {
      return Tooltip(
        message: withShortcut(label, 'Ctrl+N'),
        child: FilledButton(onPressed: onPressed, style: style, child: icon),
      );
    }
    final button = FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: icon,
      label: Text(label),
    );
    return touchFirst ? button : Tooltip(message: 'Ctrl+N', child: button);
  }
}
