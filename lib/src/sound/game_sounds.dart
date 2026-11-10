import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The sounds of the games. Each one is a role, not a file: some roles have
/// more than one take, so that a card never sounds twice exactly the same.
enum GameSound {
  /// A card turning face up.
  flip(3),

  /// A card landing on a column, a cell or a foundation.
  place(3),

  /// A move the rules do not allow.
  refuse(1),

  /// A row of cards dealt.
  deal(1),

  /// The deck shuffled for a new game.
  shuffle(1),

  /// A whole sequence flying to its nest.
  gather(1),

  /// Two birds joining into the next.
  join(1),

  /// The end of a won game.
  victory(1),

  /// A leaf lifted.
  leaf(1),

  /// A feather put on a leaf, or taken away.
  feather(1),

  /// The cat found under a leaf.
  cat(1),

  /// An egg cracking open.
  hatch(1),

  /// The cockatiel, when it peeks at the table.
  chirp(2);

  const GameSound(this.takes);

  final int takes;

  /// The asset of each take.
  List<String> get assets => [
    if (takes == 1)
      'packages/psito_games_ui/assets/sounds/$name.wav'
    else
      for (var take = 1; take <= takes; take++)
        'packages/psito_games_ui/assets/sounds/${name}_$take.wav',
  ];
}

/// Where the games send their sounds. The tests give a [RecordedSounds].
abstract interface class SoundBoard {
  /// Plays [sound] now, or after [delay], such as when a card lands at the
  /// end of its flight.
  void play(GameSound sound, {Duration delay = Duration.zero});
}

/// What plays the sounds. Kept apart so that [GameSounds] can be tested
/// without an audio device.
abstract interface class SoundOutput {
  Future<void> start(List<String> assets);
  void play(String asset, double volume);
}

/// The sounds of a game, with the mute that the bar shows. One for the whole
/// game, in [GameSounds.shared].
class GameSounds extends ChangeNotifier implements SoundBoard {
  GameSounds({SoundOutput? output, Random? random})
    : _output = output ?? _SoLoudOutput(),
      _random = random ?? Random();

  /// The sounds of this game. Silent until [start].
  static final shared = GameSounds();

  static const _mutedKey = 'psito_sounds_muted';

  /// How loud the game plays, under the volume of the system.
  static const volume = .8;

  final SoundOutput _output;
  final Random _random;
  final Map<GameSound, int> _lastTake = {};
  final Map<GameSound, Duration> _lastPlayed = {};
  final Stopwatch _clock = Stopwatch()..start();
  bool _ready = false;
  bool _muted = false;

  bool get muted => _muted;

  /// Opens the audio device and loads the sounds. Until it ends, and if it
  /// fails, the game stays silent.
  Future<void> start() async {
    try {
      _muted =
          (await SharedPreferences.getInstance()).getBool(_mutedKey) ?? false;
      notifyListeners();
    } on Object catch (error) {
      debugPrint('the sound setting could not be read: $error');
    }
    try {
      await _output.start([
        for (final sound in GameSound.values) ...sound.assets,
      ]);
      _ready = true;
    } on Object catch (error) {
      debugPrint('the sounds could not start: $error');
    }
  }

  Future<void> setMuted(bool muted) async {
    if (muted == _muted) return;
    _muted = muted;
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setBool(_mutedKey, muted);
    } on Object catch (error) {
      debugPrint('the sound setting could not be saved: $error');
    }
  }

  Future<void> toggleMuted() => setMuted(!_muted);

  @override
  void play(GameSound sound, {Duration delay = Duration.zero}) {
    if (!_ready || _muted) return;
    if (delay > Duration.zero) {
      Timer(delay, () => play(sound));
      return;
    }
    // The same sound twice in a breath, as when the cards go home one after
    // the other, would only be louder.
    final now = _clock.elapsed;
    final last = _lastPlayed[sound];
    if (last != null && now - last < const Duration(milliseconds: 45)) return;
    _lastPlayed[sound] = now;
    _output.play(sound.assets[_take(sound)], volume);
  }

  /// A take different from the last one, when there is more than one.
  int _take(GameSound sound) {
    if (sound.takes == 1) return 0;
    final last = _lastTake[sound];
    var take = _random.nextInt(sound.takes - (last == null ? 0 : 1));
    if (last != null && take >= last) take++;
    return _lastTake[sound] = take;
  }
}

class _SoLoudOutput implements SoundOutput {
  final Map<String, AudioSource> _sources = {};

  @override
  Future<void> start(List<String> assets) async {
    final soloud = SoLoud.instance;
    if (!soloud.isInitialized) await soloud.init(bufferSize: 1024);
    for (final asset in assets) {
      _sources[asset] = await soloud.loadAsset(asset);
    }
  }

  @override
  void play(String asset, double volume) {
    final source = _sources[asset];
    if (source == null) return;
    try {
      SoLoud.instance.play(source, volume: volume);
    } on SoLoudException catch (error) {
      debugPrint('a sound could not play: $error');
    }
  }
}

/// For the tests: keeps what the game asked to play.
class RecordedSounds implements SoundBoard {
  final played = <GameSound>[];

  @override
  void play(GameSound sound, {Duration delay = Duration.zero}) =>
      played.add(sound);

  void clear() => played.clear();
}
