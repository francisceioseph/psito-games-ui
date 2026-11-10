import 'package:flutter/foundation.dart';

/// Phones and tablets, where the game is played with the fingers and there
/// is no keyboard to speak of.
bool get touchFirst =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// [label] with the [keys] that do the same, except where there is no
/// keyboard.
String withShortcut(String label, String keys) =>
    touchFirst ? label : '$label  ($keys)';
