import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

const palette = GamePalette(
  felt: Color(0xFF4A3B52),
  feltGlow: Color(0xFF5E4C68),
  feltDark: Color(0xFF382C40),
  feltLight: Color(0xFFA796B2),
  barTop: Color(0xFF35293D),
  barBottom: Color(0xFF2A2031),
  onFelt: Color(0xFFF3EFE0),
  onFeltMuted: Color(0xFFC3B3CC),
);

const info = GameInfo(
  title: 'Psito Test',
  version: '1.2.3',
  howToPlay: 'Lift every leaf.',
  about: 'A game for the tests.',
  legal: 'Apache 2.0',
  site: 'https://example.org/',
);

Widget app(Widget home, {String locale = 'pt'}) => MaterialApp(
  locale: Locale(locale),
  theme: gameTheme(palette),
  localizationsDelegates: GamesUiLocalizations.localizationsDelegates,
  supportedLocales: GamesUiLocalizations.supportedLocales,
  home: home,
);

Future<void> setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget bar({VoidCallback? onNewGame, VoidCallback? onBestGames}) => GameBar(
  info: info,
  onNewGame: onNewGame ?? () {},
  onBestGames: onBestGames ?? () {},
  menu: [GameMenuEntry(label: 'Extra', onSelected: () {})],
  stats: (space) => StatsPill(
    children: [
      if (!space.narrow) const StatTile(label: 'Jogo', value: '7'),
      ClockStat(seconds: () => 65),
    ],
  ),
  actions: (space) => [
    BarButton(tooltip: 'Desfazer', icon: Icons.undo, onPressed: null),
  ],
);

void main() {
  testWidgets('the bar fits from a narrow window to a wide one', (
    tester,
  ) async {
    for (final width in const [400.0, 480.0, 700.0, 1280.0, 1920.0]) {
      await setSize(tester, Size(width, 400));
      await tester.pumpWidget(
        app(Scaffold(body: Column(children: [bar()]))),
      );
      expect(tester.takeException(), isNull, reason: '$width');
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('wide, the bar shows the name, the words and the best games', (
    tester,
  ) async {
    var best = 0;
    var started = 0;
    await setSize(tester, const Size(1280, 400));
    await tester.pumpWidget(
      app(
        Scaffold(
          body: Column(
            children: [
              bar(onBestGames: () => best++, onNewGame: () => started++),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Psito Test'), findsOneWidget);
    expect(find.text('TEMPO'), findsOneWidget);
    expect(find.text('1:05'), findsOneWidget);
    await tester.tap(find.text('Novo jogo'));
    await tester.tap(find.byTooltip('Melhores partidas'));
    expect((started, best), (1, 1));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('narrow, the best games and the sound go into the menu, before the help', (
    tester,
  ) async {
    var best = 0;
    await setSize(tester, const Size(480, 400));
    await tester.pumpWidget(
      app(Scaffold(body: Column(children: [bar(onBestGames: () => best++)]))),
    );
    expect(find.text('Psito Test'), findsNothing);
    expect(find.byTooltip('Melhores partidas'), findsNothing);
    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();
    final lines = tester
        .widgetList<PopupMenuItem<GameMenuEntry>>(
          find.byType(PopupMenuItem<GameMenuEntry>),
        )
        .map((item) => item.value!.label);
    expect(lines, [
      'Melhores partidas',
      'Extra',
      'Desligar os sons',
      'Como jogar',
      'Sobre',
    ]);
    await tester.tap(find.text('Melhores partidas'));
    await tester.pumpAndSettle();
    expect(best, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the help and the about box come from the game', (
    tester,
  ) async {
    await setSize(tester, const Size(1280, 800));
    await tester.pumpWidget(
      app(Scaffold(body: Column(children: [bar()]))),
    );
    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Como jogar'));
    await tester.pumpAndSettle();
    expect(find.text('Lift every leaf.'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sobre'));
    await tester.pumpAndSettle();
    expect(find.text('A game for the tests.'), findsOneWidget);
    expect(find.text('1.2.3'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the texts follow the language', (tester) async {
    await setSize(tester, const Size(1280, 400));
    for (final (locale, text) in const [
      ('en', 'New game'),
      ('es', 'Nueva partida'),
      ('fr', 'Nouvelle partie'),
      ('de', 'Neues Spiel'),
      ('ru', 'Новая игра'),
      ('zh', '新游戏'),
    ]) {
      await tester.pumpWidget(
        app(Scaffold(body: Column(children: [bar()])), locale: locale),
      );
      expect(find.text(text), findsOneWidget, reason: locale);
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the choice button shows the current one and picks another', (
    tester,
  ) async {
    String? chosen;
    await tester.pumpWidget(
      app(
        Scaffold(
          body: ChoiceButton<String>(
            tooltip: 'Dificuldade',
            current: 'easy',
            choices: const ['easy', 'hard'],
            label: (c) => c.toUpperCase(),
            menuLabel: (c) => '$c, in full',
            onSelected: (c) => chosen = c,
          ),
        ),
      ),
    );
    expect(find.text('EASY'), findsOneWidget);
    await tester.tap(find.text('EASY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('hard, in full'));
    await tester.pumpAndSettle();
    expect(chosen, 'hard');
  });

  testWidgets('the victory card saves the name and shows the table', (
    tester,
  ) async {
    String? saved;
    await tester.pumpWidget(
      app(
        Scaffold(
          body: VictoryCard(
            title: 'Venceu!',
            summary: 'Em 1:05',
            lastName: () async => 'Ana',
            onSave: (name) async {
              saved = name;
              return ScoreTable<String>(
                scores: [name, 'Bia'],
                highlight: name,
                name: (s) => s,
                details: (s) => [Text('${s.length}')],
              );
            },
            onNewGame: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Ana'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Caio');
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    await tester.pump();
    expect(saved, 'Caio');
    expect(find.text('Melhores partidas'), findsOneWidget);
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('Jogar de novo'), findsOneWidget);
  });

  testWidgets('an empty table says that no game was won', (tester) async {
    await tester.pumpWidget(
      app(
        Scaffold(
          body: ScoreTable<String>(
            scores: const [],
            name: (s) => s,
            details: (s) => const [],
          ),
        ),
      ),
    );
    expect(find.text('Nenhuma partida vencida ainda.'), findsOneWidget);
  });

  testWidgets('the game number dialog takes only positive numbers', (
    tester,
  ) async {
    int? chosen;
    await tester.pumpWidget(
      app(Scaffold(body: ChooseGameDialog(onChosen: (n) => chosen = n))),
    );
    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();
    await tester.tap(find.text('Jogar'));
    expect(chosen, isNull);
    await tester.enterText(find.byType(TextField), '42');
    await tester.pump();
    await tester.tap(find.text('Jogar'));
    expect(chosen, 42);
  });

  testWidgets('the cockatiel peeks when idle and goes away on activity', (
    tester,
  ) async {
    final peek = PeekController();
    addTearDown(peek.dispose);
    await setSize(tester, const Size(800, 600));
    await tester.pumpWidget(
      app(
        GameTable(
          peek: peek,
          bar: const SizedBox(height: 40),
          board: const SizedBox(),
          overlays: const [Center(child: Text('board'))],
        ),
      ),
    );
    expect(find.byType(Peek), findsNothing);
    await tester.pump(const Duration(seconds: 46));
    expect(tester.widget<Peek>(find.byType(Peek)).visible, isTrue);

    peek.activity();
    await tester.pump();
    expect(tester.widget<Peek>(find.byType(Peek)).visible, isFalse);

    // Activity keeps it away.
    await tester.pump(const Duration(seconds: 30));
    peek.activity();
    await tester.pump(const Duration(seconds: 30));
    expect(tester.widget<Peek>(find.byType(Peek)).visible, isFalse);

    peek.peekNow();
    await tester.pump();
    expect(tester.widget<Peek>(find.byType(Peek)).visible, isTrue);
    await tester.pump(const Duration(seconds: 4));
    expect(tester.widget<Peek>(find.byType(Peek)).visible, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a click on the table counts as activity', (tester) async {
    await setSize(tester, const Size(800, 600));
    await tester.pumpWidget(
      app(
        const GameTable(
          bar: SizedBox(height: 40),
          board: Center(child: Text('board')),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 40));
    await tester.tap(find.text('board'));
    await tester.pump(const Duration(seconds: 10));
    expect(find.byType(Peek), findsNothing);
    await tester.pump(const Duration(seconds: 40));
    expect(find.byType(Peek), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test('the time is shown as minutes and seconds', () {
    expect(formatTime(5), '0:05');
    expect(formatTime(125), '2:05');
    expect(formatTime(4500), '75:00');
  });

  test('the next spot is never on the same edge', () {
    final random = Random(3);
    PeekSpot? spot;
    for (var i = 0; i < 40; i++) {
      final next = nextPeekSpot(random, spot);
      expect(next.edge, isNot(spot?.edge));
      spot = next;
    }
  });
}
