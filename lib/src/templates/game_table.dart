import 'package:flutter/material.dart';

import '../organisms/idle_peek.dart';
import '../theme/game_palette.dart';

/// The page of a game: the bar on top and, below it, the felt with the
/// board, whatever goes over it and the cockatiel that peeks.
class GameTable extends StatefulWidget {
  const GameTable({
    super.key,
    required this.bar,
    required this.board,
    this.overlays = const [],
    this.shortcuts = const {},
    this.peek,
  });

  final Widget bar;
  final Widget board;

  /// What goes over the board, such as the panel of a won game.
  final List<Widget> overlays;
  final Map<ShortcutActivator, VoidCallback> shortcuts;

  /// To send the cockatiel away or call it from the game. Without one, the
  /// table keeps its own.
  final PeekController? peek;

  @override
  State<GameTable> createState() => _GameTableState();
}

class _GameTableState extends State<GameTable> {
  PeekController? _own;

  PeekController get _peek => widget.peek ?? (_own ??= PeekController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.felt,
      body: CallbackShortcuts(
        bindings: widget.shortcuts,
        child: Focus(
          autofocus: true,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _peek.activity(),
            child: Column(
              children: [
                widget.bar,
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // The felt runs under the system bars of a phone...
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            radius: 1.1,
                            colors: [
                              palette.feltGlow,
                              palette.felt,
                              palette.feltDark,
                            ],
                            stops: const [0, .6, 1],
                          ),
                        ),
                      ),
                      // ...and the board stays clear of them. The bar
                      // takes the top inset.
                      SafeArea(
                        top: false,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            widget.board,
                            ...widget.overlays,
                            IdlePeek(controller: _peek),
                          ],
                        ),
                      ),
                    ],
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
