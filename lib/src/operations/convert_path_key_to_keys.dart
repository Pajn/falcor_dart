library falcor_dart.convert_path_key_to;

import 'package:falcor_dart/src/types/range.dart';

onKey(List out, key) {
  out.add(key);
}

onRange(List out, Range range) {
  out.addAll(range.toList());
}
