import 'package:flutter/material.dart';

import '../l10n.dart';
import '../sound/game_sounds.dart';
import 'bar_button.dart';

/// The button of the bar that turns the sounds off and on again.
class SoundButton extends StatelessWidget {
  const SoundButton({super.key, this.sounds});

  /// The sounds it turns off. Without one, those of the game.
  final GameSounds? sounds;

  @override
  Widget build(BuildContext context) {
    final sounds = this.sounds ?? GameSounds.shared;
    final l10n = context.gamesUi;
    return ListenableBuilder(
      listenable: sounds,
      builder: (context, _) => BarButton(
        tooltip: sounds.muted ? l10n.soundOn : l10n.soundOff,
        icon: sounds.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
        onPressed: sounds.toggleMuted,
      ),
    );
  }
}
