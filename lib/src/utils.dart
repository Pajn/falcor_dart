library falcor_dart.utils.dart;

import 'package:falcor_dart/src/keys.dart';
import 'dart:convert';

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

bool isJSONG(output) {
  return output is Map && output.containsKey('jsonGraph');
}

bool isPathValue(output) {
  return output is Map && output.containsKey('path') && output.containsKey('value');
}

bool isRoutedToken(output) {
  return output is Map && output.containsKey('type') && output.containsKey('named');
}

prettifyRoute(Iterable route) {
  var length = 0;
  var str = [];

  route = route.toList();

  for (var i = 0, len = route.length; i < len; ++i, ++length) {
    var value = route[i];
    if (value is Map) {
      value = value['type'];
    }

    if (value == Keys.integers) {
      str.add('integers');
    }

    else if (value == Keys.ranges) {
      str.add('ranges');
    }

    else if (value == Keys.keys) {
      str.add('keys');
    }

    else {
      if (value is List) {
        str.add(JSON.encode(value));
      }

      else {
        str.add(value);
      }
    }
  }

  return str;
}
