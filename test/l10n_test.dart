import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

Map<String, dynamic> arb(String language) =>
    jsonDecode(File('lib/l10n/games_ui_$language.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> keys(String language) =>
    arb(language).keys.where((key) => !key.startsWith('@')).toSet();

void main() {
  const languages = ['en', 'pt', 'es', 'fr', 'de', 'ru', 'zh'];

  test('the same languages as Psito Player', () {
    expect(
      GamesUiLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      languages.toSet(),
    );
  });

  test('English comes first, for the systems in other languages', () {
    expect(GamesUiLocalizations.supportedLocales.first, const Locale('en'));
  });

  test('every language has every text, none of them empty', () {
    for (final language in languages) {
      expect(keys(language), keys('en'), reason: language);
      for (final key in keys(language)) {
        expect(
          (arb(language)[key] as String).trim(),
          isNotEmpty,
          reason: '$language $key',
        );
      }
    }
  });
}
