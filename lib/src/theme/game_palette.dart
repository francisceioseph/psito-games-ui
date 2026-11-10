import 'package:flutter/material.dart';

/// The colours of a game's table. Each game has its own felt, and the shared
/// widgets take them from the theme.
@immutable
class GamePalette extends ThemeExtension<GamePalette> {
  const GamePalette({
    required this.felt,
    required this.feltGlow,
    required this.feltDark,
    required this.feltLight,
    required this.barTop,
    required this.barBottom,
    required this.onFelt,
    required this.onFeltMuted,
    this.cream = const Color(0xFFF6EED6),
    this.ink = const Color(0xFF3B3842),
  });

  /// The table, with the lighter centre and the darker edges of its glow.
  final Color felt;
  final Color feltGlow;
  final Color feltDark;

  /// The felt seen through a disabled button.
  final Color feltLight;

  /// The two ends of the gradient of the bar.
  final Color barTop;
  final Color barBottom;

  /// Text and icons over the felt and the bar.
  final Color onFelt;
  final Color onFeltMuted;

  /// The paper of the cards and the panels, and the text on it.
  final Color cream;
  final Color ink;

  @override
  GamePalette copyWith({
    Color? felt,
    Color? feltGlow,
    Color? feltDark,
    Color? feltLight,
    Color? barTop,
    Color? barBottom,
    Color? onFelt,
    Color? onFeltMuted,
    Color? cream,
    Color? ink,
  }) => GamePalette(
    felt: felt ?? this.felt,
    feltGlow: feltGlow ?? this.feltGlow,
    feltDark: feltDark ?? this.feltDark,
    feltLight: feltLight ?? this.feltLight,
    barTop: barTop ?? this.barTop,
    barBottom: barBottom ?? this.barBottom,
    onFelt: onFelt ?? this.onFelt,
    onFeltMuted: onFeltMuted ?? this.onFeltMuted,
    cream: cream ?? this.cream,
    ink: ink ?? this.ink,
  );

  @override
  GamePalette lerp(GamePalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return GamePalette(
      felt: mix(felt, other.felt),
      feltGlow: mix(feltGlow, other.feltGlow),
      feltDark: mix(feltDark, other.feltDark),
      feltLight: mix(feltLight, other.feltLight),
      barTop: mix(barTop, other.barTop),
      barBottom: mix(barBottom, other.barBottom),
      onFelt: mix(onFelt, other.onFelt),
      onFeltMuted: mix(onFeltMuted, other.onFeltMuted),
      cream: mix(cream, other.cream),
      ink: mix(ink, other.ink),
    );
  }
}

/// The theme of a game: Material seeded from its felt, with its palette.
ThemeData gameTheme(GamePalette palette) => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: palette.felt,
    brightness: Brightness.light,
  ),
  extensions: [palette],
);

extension GamePaletteOf on BuildContext {
  /// The palette of the game, or a neutral one in a bare test.
  GamePalette get palette =>
      Theme.of(this).extension<GamePalette>() ?? _fallback;
}

const _fallback = GamePalette(
  felt: Color(0xFF426854),
  feltGlow: Color(0xFF527F68),
  feltDark: Color(0xFF34543F),
  feltLight: Color(0xFF7FA38F),
  barTop: Color(0xFF2F4A3A),
  barBottom: Color(0xFF263E30),
  onFelt: Color(0xFFF3EFE0),
  onFeltMuted: Color(0xFFA9C3B3),
);
