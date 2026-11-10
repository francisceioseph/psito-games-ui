import 'package:flutter/material.dart';

import '../l10n.dart';

/// The best games, one per line with its place, the name and what the game
/// counts, and the [highlight] one in bold.
class ScoreTable<T> extends StatelessWidget {
  const ScoreTable({
    super.key,
    required this.scores,
    required this.name,
    required this.details,
    this.highlight,
  });

  final List<T> scores;
  final String Function(T score) name;

  /// What comes after the name: the moves, the time, the points.
  final List<Widget> Function(T score) details;
  final T? highlight;

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return Text(context.gamesUi.noScores);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < scores.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: DefaultTextStyle.merge(
              style: identical(scores[i], highlight)
                  ? const TextStyle(fontWeight: FontWeight.w800)
                  : null,
              child: Row(
                children: [
                  SizedBox(width: 28, child: Text('${i + 1}.')),
                  Expanded(
                    child: Text(
                      name(scores[i]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ...details(scores[i]),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
