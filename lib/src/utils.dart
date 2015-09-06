library falcor_dart.utils.dart;

/// True if value is num or can be parsed to num
bool isNumeric(value) {
  if (value is num) return true;
  if (value is! String) return false;

  return !num.parse(value, (_) => double.NAN).isNaN;
}

/// True if value is num or can be parsed to num
num parseNum(value) {
  if (value is num) return value;
  if (value is! String) return double.NAN;

  return num.parse(value, (_) => double.NAN);
}

List catAndSlice(List a, List b, [int slice = 0]) {
  var next = new List.from(a);

  for (; slice < b.length; ++slice) {
    next.add(b[slice]);
  }

  return next;
}

bool isMessage(Map output) {
  return output.containsKey('isMessage');
}

bool isJSONG(Map output) {
  return output.containsKey('jsonGraph');
}

bool isPathValue(Map output) {
  return output.containsKey('path') && output.containsKey('value');
}

bool isRoutedToken(Map output) {
  return output.containsKey('type') && output.containsKey('named');
}
