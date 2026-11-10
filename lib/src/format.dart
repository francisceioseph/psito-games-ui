/// A time played as minutes and seconds: 0:05, 2:05, 75:00.
String formatTime(int seconds) {
  final minutes = seconds ~/ 60;
  final rest = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}
