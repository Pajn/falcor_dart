library falcor_dart.convert_path_key_to_integers;

import 'package:falcor_dart/src/types/range.dart';
import 'package:falcor_dart/src/utils.dart';

void onRange(List out, Range range) {
  out.add(range);
}

/**
 * @param {Number|String} key must be a number
 */
Range keyReduce(List out, key, Range range) {
  if (!isNumeric(key)) {
    return range;
  }

  key = parseNum(key);
  if (range != null) {
    if (key - 1 == range.to) {
      range.to = key;
    }

    else if (key + 1 == range.from) {
      range.from = key;
    }

    else {
      range = null;
    }
  }

  if (range == null) {
    range = new Range(key, key);
    out.add(range);
  }

  return range;
}
