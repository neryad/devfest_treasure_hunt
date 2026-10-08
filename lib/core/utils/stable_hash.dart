/// Stable hash function for deterministic selection across platforms/runs.
///
/// The value is deliberately kept to 31 bits. That range is represented
/// exactly by both native Dart integers and JavaScript numbers, so Flutter Web
/// assigns the same question as Android and iOS.
int stableHash(String input) {
  var hash = 0;
  for (var i = 0; i < input.length; i++) {
    hash = ((hash * 31) + input.codeUnitAt(i)) & 0x7fffffff;
  }
  return hash;
}
