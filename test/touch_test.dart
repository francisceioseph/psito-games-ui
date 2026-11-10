import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

import 'widgets_test.dart' show app, bar, setSize;

void main() {
  testWidgets('on a phone the keys leave the tooltips', (tester) async {
    expect(withShortcut('Desfazer', 'Ctrl+Z'), 'Desfazer');
    await setSize(tester, const Size(360, 700));
    await tester.pumpWidget(app(Scaffold(body: Column(children: [bar()]))));
    expect(find.byTooltip('Novo jogo'), findsOneWidget);
    expect(find.byTooltip('Novo jogo  (Ctrl+N)'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('on the desktop the tooltips keep the keys', (tester) async {
    expect(withShortcut('Desfazer', 'Ctrl+Z'), 'Desfazer  (Ctrl+Z)');
  }, variant: TargetPlatformVariant.desktop());

  testWidgets('the bar goes under the status bar, the board above the '
      'gesture bar', (tester) async {
    await setSize(tester, const Size(360, 700));
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 16);
    addTearDown(tester.view.resetPadding);
    await tester.pumpWidget(
      app(
        GameTable(
          bar: bar(),
          board: const SizedBox.expand(key: Key('board')),
        ),
      ),
    );
    expect(tester.getTopLeft(find.byType(GameBar)).dy, 0);
    final brand = tester.getTopLeft(find.byType(GameBrand));
    expect(brand.dy, greaterThanOrEqualTo(24));
    expect(tester.getBottomLeft(find.byKey(const Key('board'))).dy, 700 - 16);
    await tester.pumpWidget(const SizedBox());
  });
}
