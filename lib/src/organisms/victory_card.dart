import 'package:flutter/material.dart';

import '../l10n.dart';
import '../theme/game_palette.dart';

/// The end of a good game: it asks for the player's name and, once saved,
/// shows where the game landed among the best ones.
class VictoryCard extends StatefulWidget {
  const VictoryCard({
    super.key,
    required this.title,
    required this.summary,
    required this.lastName,
    required this.onSave,
    required this.onNewGame,
  });

  final String title;
  final String summary;

  /// The name used last time, to fill the field.
  final Future<String> Function() lastName;

  /// Saves the game under the name and gives the table of the best games.
  final Future<Widget> Function(String name) onSave;
  final VoidCallback onNewGame;

  @override
  State<VictoryCard> createState() => _VictoryCardState();
}

class _VictoryCardState extends State<VictoryCard> {
  final _name = TextEditingController();
  Widget? _scores;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    widget.lastName().then((name) {
      if (mounted && _name.text.isEmpty) _name.text = name;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || _saving) return;
    _saving = true;
    final scores = await widget.onSave(name);
    if (mounted) setState(() => _scores = scores);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.gamesUi;
    final palette = context.palette;
    final scores = _scores;
    return Card(
      color: palette.cream,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(widget.summary),
              const SizedBox(height: 16),
              if (scores == null) ...[
                TextField(
                  controller: _name,
                  autofocus: true,
                  maxLength: 20,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    labelText: l10n.yourName,
                    border: const OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.onNewGame,
                      child: Text(l10n.skip),
                    ),
                    const SizedBox(width: 8),
                    ListenableBuilder(
                      listenable: _name,
                      builder: (context, _) => FilledButton(
                        onPressed: _name.text.trim().isEmpty ? null : _save,
                        child: Text(l10n.save),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  l10n.bestGames,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                scores,
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: widget.onNewGame,
                  child: Text(l10n.playAgain),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
