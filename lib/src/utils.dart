library falcor_dart.utils.dart;

/// True if value is num or can be parsed to num
bool isNumeric(value) {
  if (value is num) return true;

  return !num.parse(value, (_) => double.NAN).isNaN;
}

/// True if value is num or can be parsed to num
num parseNum(value) {
  if (value is num) return value;

  return num.parse(value, (_) => double.NAN);
}
