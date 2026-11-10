import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import 'peek.dart';

/// Tells the cockatiel what happens at the table: any [activity] sends it
/// away and starts the wait again, and [peekNow] calls it at once, such as
/// at the end of a game.
class PeekController extends ChangeNotifier {
  int _calls = 0;
  int _activity = 0;

  void peekNow() {
    _calls++;
    notifyListeners();
  }

  void activity() {
    _activity++;
    notifyListeners();
  }
}

/// The cockatiel that peeks from a different edge after [idle] without
/// anything happening, and stays for [stay].
class IdlePeek extends StatefulWidget {
  const IdlePeek({
    super.key,
    required this.controller,
    this.idle = const Duration(seconds: 45),
    this.stay = const Duration(milliseconds: 3200),
    this.random,
  });

  final PeekController controller;
  final Duration idle;
  final Duration stay;
  final Random? random;

  @override
  State<IdlePeek> createState() => _IdlePeekState();
}

class _IdlePeekState extends State<IdlePeek> {
  late final Random _random = widget.random ?? Random();
  Timer? _timer;
  PeekSpot? _spot;
  bool _peeking = false;
  int _calls = 0;
  int _activity = 0;

  @override
  void initState() {
    super.initState();
    _follow(widget.controller);
    _waitIdle();
  }

  @override
  void didUpdateWidget(IdlePeek old) {
    super.didUpdateWidget(old);
    if (old.controller == widget.controller) return;
    old.controller.removeListener(_changed);
    _follow(widget.controller);
  }

  void _follow(PeekController controller) {
    _calls = controller._calls;
    _activity = controller._activity;
    controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _timer?.cancel();
    super.dispose();
  }

  void _changed() {
    final controller = widget.controller;
    if (controller._calls != _calls) {
      _calls = controller._calls;
      _activity = controller._activity;
      _peek();
    } else if (controller._activity != _activity) {
      _activity = controller._activity;
      if (_peeking) setState(() => _peeking = false);
      _waitIdle();
    }
  }

  void _waitIdle() {
    _timer?.cancel();
    _timer = Timer(widget.idle, _peek);
  }

  void _peek() {
    _timer?.cancel();
    setState(() {
      _spot = nextPeekSpot(_random, _spot);
      _peeking = true;
    });
    _timer = Timer(widget.stay, () {
      setState(() => _peeking = false);
      _waitIdle();
    });
  }

  @override
  Widget build(BuildContext context) => switch (_spot) {
    final spot? => Peek(key: ObjectKey(spot), spot: spot, visible: _peeking),
    null => const SizedBox.shrink(),
  };
}
