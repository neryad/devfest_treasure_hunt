String formatElapsed(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  String two(int v) => v.toString().padLeft(2, '0');
  if (h > 0) return '${two(h)}:${two(m)}';
  return '${two(m)}:${two(s)}';
}