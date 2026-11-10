import 'package:flutter/material.dart';

import '../mascot.dart';
import '../theme/game_palette.dart';

/// The cockatiel and, when there is room, the name of the game.
class GameBrand extends StatelessWidget {
  const GameBrand({super.key, required this.title, required this.showName});

  final String title;
  final bool showName;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const ExcludeSemantics(
        child: Image(
          image: mascotImage,
          height: 34,
          filterQuality: FilterQuality.medium,
        ),
      ),
      if (showName) ...[
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'CardSerif',
              fontSize: 19,
              color: context.palette.onFelt,
              letterSpacing: .2,
            ),
          ),
        ),
      ],
    ],
  );
}
