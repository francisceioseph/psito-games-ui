import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../atoms/bar_button.dart';
import '../atoms/new_game_button.dart';
import '../atoms/sound_button.dart';
import '../l10n.dart';
import '../molecules/game_brand.dart';
import '../sound/game_sounds.dart';
import '../theme/game_palette.dart';
import 'dialogs.dart';

/// How much room the bar has, for the pieces that shrink with it.
class BarSpace {
  const BarSpace(this.width);

  static const compactBelow = 860.0;
  static const narrowBelow = 600.0;

  final double width;

  /// The name of the game goes away and the buttons lose their words.
  bool get compact => width < compactBelow;

  /// Some buttons move into the menu.
  bool get narrow => width < narrowBelow;
}

/// One more line of the menu, after the best games and before the help.
class GameMenuEntry {
  const GameMenuEntry({required this.label, required this.onSelected});

  final String label;
  final VoidCallback onSelected;
}

/// The bar above the table: the brand, the numbers of the game and the
/// actions, with the new game and the menu always at the end.
class GameBar extends StatelessWidget {
  const GameBar({
    super.key,
    required this.info,
    required this.stats,
    required this.onNewGame,
    this.actions,
    this.onBestGames,
    this.menu = const [],
    this.showNameFrom = BarSpace.compactBelow,
  });

  final GameInfo info;
  final Widget Function(BarSpace space) stats;

  /// The buttons of this game, between the best games and the new game.
  final List<Widget> Function(BarSpace space)? actions;
  final VoidCallback onNewGame;

  /// Opens the best games: a button on the bar, or a line of the menu when
  /// the bar is narrow.
  final VoidCallback? onBestGames;
  final List<GameMenuEntry> menu;

  /// The width from which the name of the game shows next to the cockatiel.
  final double showNameFrom;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.gamesUi;
    // On a phone the bar runs under the status bar, which shows light icons
    // on it.
    final inset = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0x00000000),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0x00000000),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.barTop, palette.barBottom],
          ),
          border: const Border(bottom: BorderSide(color: Color(0x33000000))),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final space = BarSpace(box.maxWidth);
            final bestGames = onBestGames;
            final sounds = GameSounds.shared;
            // Read when the menu opens, so that the sound line says what it
            // will do then.
            List<GameMenuEntry> entries() => [
              if (space.narrow && bestGames != null)
                GameMenuEntry(label: l10n.bestGames, onSelected: bestGames),
              ...menu,
              if (space.narrow)
                GameMenuEntry(
                  label: sounds.muted ? l10n.soundOn : l10n.soundOff,
                  onSelected: sounds.toggleMuted,
                ),
              GameMenuEntry(
                label: l10n.howToPlay,
                onSelected: () => showHowToPlay(context, info),
              ),
              GameMenuEntry(
                label: l10n.about,
                onSelected: () => showGameAbout(context, info),
              ),
            ];
            final brand = GameBrand(
              title: info.title,
              showName: box.maxWidth >= showNameFrom,
            );
            final stats = this.stats(space);
            final actions = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!space.narrow && bestGames != null)
                  BarButton(
                    tooltip: l10n.bestGames,
                    icon: Icons.emoji_events_outlined,
                    onPressed: bestGames,
                  ),
                ...?this.actions?.call(space),
                if (!space.narrow) const SoundButton(),
                const SizedBox(width: 6),
                NewGameButton(iconOnly: space.compact, onPressed: onNewGame),
                PopupMenuButton<GameMenuEntry>(
                  tooltip: l10n.moreOptions,
                  iconColor: palette.onFelt,
                  style: IconButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.more_vert_rounded, size: 21),
                  onSelected: (entry) => entry.onSelected(),
                  itemBuilder: (context) => [
                    for (final entry in entries())
                      PopupMenuItem(value: entry, child: Text(entry.label)),
                  ],
                ),
              ],
            );
            return Padding(
              padding: EdgeInsets.fromLTRB(
                12 + inset.left,
                7 + inset.top,
                12 + inset.right,
                7,
              ),
              // The numbers are centred only when there is room on both sides.
              child: Row(
                children: space.compact
                    ? [
                        brand,
                        const SizedBox(width: 12),
                        // On a phone the numbers shrink a little rather than
                        // push the buttons out.
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: stats,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        actions,
                      ]
                    : [
                        Expanded(child: brand),
                        stats,
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: actions,
                          ),
                        ),
                      ],
              ),
            );
          },
        ),
      ),
    );
  }
}
