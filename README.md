# Psito Games UI

The widgets the Psito games share, in Flutter: [Psito Cell](https://github.com/francisceioseph/psito-cell),
[Psito Solitaire](https://github.com/francisceioseph/psito-solitaire),
[Psito Mines](https://github.com/francisceioseph/psito-mines) and
[Psito Nest](https://github.com/francisceioseph/psito-nest). A fix here reaches all four.

## What is inside

The widgets follow atomic design:

- **Atoms**: the icon buttons of the bar, the new game button and the numbers of the game.
- **Molecules**: the brand, the row of numbers, the clock, the table of the best games,
  the choice button (the difficulty, for example) and the note at the end of a game.
- **Organisms**: the bar, the cockatiel that peeks from the edges, the victory card and
  the dialogs (how to play, about, best games, choose a game number).
- **Template**: the page of a game, with the felt, the bar, the board and the cockatiel.
- **Sounds**: short, soft sounds for the cards, the leaves, the eggs and the cockatiel,
  levelled together, with the mute button on the bar. The game says what happened
  (`GameSound.place`, `GameSound.victory`...) and `GameSounds` picks a take and plays it.

Each game gives its colours as a `GamePalette`, through `gameTheme`, and its texts as a
`GameInfo`. The shared texts are in seven languages, the same as Psito Player: English,
Portuguese, Spanish, French, German, Russian and Chinese.

## Use

```yaml
dependencies:
  psito_games_ui:
    git:
      url: https://github.com/francisceioseph/psito-games-ui
      ref: v1.1.0
```

```dart
MaterialApp(
  theme: gameTheme(myPalette),
  localizationsDelegates: [
    ...AppLocalizations.localizationsDelegates,
    GamesUiLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: GameTable(bar: GameBar(...), board: MyBoard()),
);
```

The bar shows the brand in the `CardSerif` font, which each game bundles.

The sounds start in `main`, and stay silent until they are ready or if there is no audio
device. The mute is remembered on the computer:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(GameSounds.shared.start());
  runApp(const MyGameApp());
}
```

The controllers take a `SoundBoard`, which the tests replace with `RecordedSounds`. The sounds
are WAV, so the game can leave out the codecs of the sound engine in its `pubspec.yaml`:

```yaml
hooks:
  user_defines:
    flutter_soloud:
      no_xiph_libs: true
```

On Linux the engine opens ALSA when it starts, so the packages recommend `libasound2`.

To work on a game and this package together, put a `pubspec_overrides.yaml` in the game:

```yaml
dependency_overrides:
  psito_games_ui:
    path: ../psito-games-ui
```

## Texts

The `.arb` files are in `lib/l10n/`, with English as the template. After editing them,
run `flutter gen-l10n`; the generated files are kept in git.

## License

Code under the [Apache 2.0](LICENSE) license. The cockatiel and the sounds are under
[CC0](assets/LICENSE.md).
