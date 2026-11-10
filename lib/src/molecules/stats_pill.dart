import 'package:flutter/material.dart';

import '../atoms/stat_tile.dart';

/// The numbers of the game side by side, with a line between each two.
class StatsPill extends StatelessWidget {
  const StatsPill({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0x26000000),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0x14FFFFFF)),
    ),
    child: IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const StatDivider(),
            children[i],
          ],
        ],
      ),
    ),
  );
}
