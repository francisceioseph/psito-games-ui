import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n.dart';
import '../mascot.dart';

/// What a game says about itself, in the help and in the about box.
class GameInfo {
  const GameInfo({
    required this.title,
    required this.version,
    required this.howToPlay,
    required this.about,
    required this.legal,
    required this.site,
  });

  final String title;
  final String version;
  final String howToPlay;
  final String about;
  final String legal;
  final String site;
}

/// A dialog with a title, some content and a button to close it.
class InfoDialog extends StatelessWidget {
  const InfoDialog({
    super.key,
    required this.title,
    required this.child,
    this.width = 420,
  });

  final String title;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: SizedBox(width: width, child: child),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.gamesUi.close),
      ),
    ],
  );
}

void showHowToPlay(BuildContext context, GameInfo info) => showDialog<void>(
  context: context,
  builder: (context) => InfoDialog(
    title: context.gamesUi.howToPlay,
    child: SingleChildScrollView(child: Text(info.howToPlay)),
  ),
);

void showGameAbout(BuildContext context, GameInfo info) => showAboutDialog(
  context: context,
  applicationName: info.title,
  applicationVersion: info.version,
  applicationIcon: const Image(image: mascotImage, width: 48),
  applicationLegalese: info.legal,
  children: [
    const SizedBox(height: 16),
    Text(info.about),
    const SizedBox(height: 8),
    SelectableText(info.site),
  ],
);

/// The best games, in a dialog. [child] is the table, often waiting for the
/// scores to load.
void showBestGames(BuildContext context, Widget child) => showDialog<void>(
  context: context,
  builder: (context) =>
      InfoDialog(title: context.gamesUi.bestGames, width: 340, child: child),
);

/// Asks for the number of a game to deal again.
class ChooseGameDialog extends StatefulWidget {
  const ChooseGameDialog({super.key, required this.onChosen});

  final void Function(int number) onChosen;

  @override
  State<ChooseGameDialog> createState() => _ChooseGameDialogState();
}

class _ChooseGameDialogState extends State<ChooseGameDialog> {
  final _number = TextEditingController();

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  int? get _value {
    final value = int.tryParse(_number.text);
    return value != null && value > 0 ? value : null;
  }

  void _submit() {
    final value = _value;
    if (value == null) return;
    Navigator.of(context).pop();
    widget.onChosen(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.gamesUi;
    return AlertDialog(
      title: Text(l10n.chooseGame),
      content: TextField(
        controller: _number,
        autofocus: true,
        maxLength: 6,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: l10n.statGame,
          border: const OutlineInputBorder(),
          counterText: '',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ListenableBuilder(
          listenable: _number,
          builder: (context, _) => FilledButton(
            onPressed: _value == null ? null : _submit,
            child: Text(l10n.play),
          ),
        ),
      ],
    );
  }
}
