library falcor_dart.convert_path_key_to_integers;

import 'package:falcor_dart/src/types/range.dart';
import 'package:falcor_dart/src/operations/convert_path_key_to.dart';

void onRange(List out, Range range) => out.addAll(range.toList());

void onKey(List out, key, [_]) {
  if (key is String) {
    key = int.parse(key, onError: (_) => null);
  }
  if (key is int) {
    out.add(key);
  }
}

/**
 * will attempt to get integers from the key
 * or keySet provided. assumes everything passed in is an integer
 * or range of integers.
 */
var convertPathKeyToIntegers = convertPathKeyTo(onRange, onKey);
