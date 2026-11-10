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

Each game gives its colours as a `GamePalette`, through `gameTheme`, and its texts as a
`GameInfo`. The shared texts are in seven languages, the same as Psito Player: English,
Portuguese, Spanish, French, German, Russian and Chinese.

## Use

```yaml
dependencies:
  psito_games_ui:
    git:
      url: https://github.com/francisceioseph/psito-games-ui
      ref: v1.0.0
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

Code under the [Apache 2.0](LICENSE) license. The cockatiel is under [CC0](assets/LICENSE.md).
