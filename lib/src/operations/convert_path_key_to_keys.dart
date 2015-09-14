library falcor_dart.convert_path_key_to;

import 'package:falcor_dart/src/types/range.dart';
import 'package:falcor_dart/src/operations/convert_path_key_to.dart';

void onKey(List out, key, [_]) {
  out.add(key);
}

void onRange(List out, Range range) {
  out.addAll(range.toList());
}

var convertPathKeyToKeys = convertPathKeyTo(onRange, onKey);
