library falcor_dart.convert_path_key_to_integers;

import 'package:falcor_dart/src/types/range.dart';

onRange(List out, Range range) => out.addAll(range.toList());

onKey(List out, key) {
  if (key is String) {
    key = int.parse(key, onError: (_) => null);
  }
  if (key is int) {
    out.add(key);
  }
}
