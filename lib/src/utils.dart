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
