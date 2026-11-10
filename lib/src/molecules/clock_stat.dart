import 'dart:async';

import 'package:flutter/material.dart';

import '../atoms/stat_tile.dart';
import '../format.dart';
import '../l10n.dart';

/// The time played, read again once per second.
class ClockStat extends StatefulWidget {
  const ClockStat({super.key, required this.seconds});

  final int Function() seconds;

  @override
  State<ClockStat> createState() => _ClockStatState();
}

class _ClockStatState extends State<ClockStat> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StatTile(
    label: context.gamesUi.statTime,
    value: formatTime(widget.seconds()),
  );
}
