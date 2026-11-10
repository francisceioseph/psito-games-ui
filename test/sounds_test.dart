import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psito_games_ui/psito_games_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeOutput implements SoundOutput {
  final loaded = <String>[];
  final played = <String>[];

  @override
  Future<void> start(List<String> assets) async => loaded.addAll(assets);

  @override
  void play(String asset, double volume) => played.add(asset.split('/').last);
}

void main() {
  late FakeOutput output;
  late GameSounds sounds;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    output = FakeOutput();
    sounds = GameSounds(output: output, random: Random(1));
  });

  test('every take of every sound is in the package', () {
    for (final sound in GameSound.values) {
      for (final asset in sound.assets) {
        final file = asset.replaceFirst('packages/psito_games_ui/', '');
        expect(File(file).existsSync(), isTrue, reason: file);
      }
    }
  });

  test('silent until started, and then plays', () async {
    sounds.play(GameSound.place);
    expect(output.played, isEmpty);
    await sounds.start();
    expect(output.loaded, hasLength(greaterThan(GameSound.values.length)));
    sounds.play(GameSound.victory);
    expect(output.played, ['victory.wav']);
  });

  test('a take never repeats the one before', () async {
    await sounds.start();
    String? last;
    for (var i = 0; i < 20; i++) {
      sounds.play(GameSound.flip, delay: Duration.zero);
      expect(output.played.last, isNot(last));
      last = output.played.last;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  });

  test('the same sound twice in a breath plays once', () async {
    await sounds.start();
    sounds
      ..play(GameSound.leaf)
      ..play(GameSound.leaf)
      ..play(GameSound.cat);
    expect(output.played, ['leaf.wav', 'cat.wav']);
  });

  test('a delayed sound waits', () async {
    await sounds.start();
    sounds.play(GameSound.gather, delay: const Duration(milliseconds: 60));
    expect(output.played, isEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(output.played, ['gather.wav']);
  });

  test('the mute holds and is remembered', () async {
    await sounds.start();
    await sounds.setMuted(true);
    sounds.play(GameSound.deal);
    expect(output.played, isEmpty);

    final again = GameSounds(output: FakeOutput());
    await again.start();
    expect(again.muted, isTrue);
  });

  test('a device that fails leaves the game silent, not broken', () async {
    final broken = GameSounds(output: _BrokenOutput());
    await broken.start();
    broken.play(GameSound.flip);
  });

  testWidgets('the button of the bar turns the sounds off and on', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: GamesUiLocalizations.localizationsDelegates,
        supportedLocales: GamesUiLocalizations.supportedLocales,
        home: Scaffold(body: SoundButton(sounds: sounds)),
      ),
    );
    await tester.tap(find.byTooltip('Desligar os sons'));
    await tester.pump();
    expect(sounds.muted, isTrue);
    expect(find.byTooltip('Ligar os sons'), findsOneWidget);
    await tester.tap(find.byTooltip('Ligar os sons'));
    await tester.pump();
    expect(sounds.muted, isFalse);
  });

  testWidgets('the cockatiel chirps when it peeks', (tester) async {
    final recorded = RecordedSounds();
    final peek = PeekController();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            IdlePeek(
              controller: peek,
              idle: const Duration(seconds: 1),
              sounds: recorded,
            ),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(recorded.played, [GameSound.chirp]);
    peek.peekNow();
    await tester.pump();
    expect(recorded.played, [GameSound.chirp, GameSound.chirp]);
    await tester.pump(const Duration(seconds: 5));
  });
}

class _BrokenOutput implements SoundOutput {
  @override
  Future<void> start(List<String> assets) async =>
      throw StateError('no device');

  @override
  void play(String asset, double volume) => fail('nothing should play');
}
