library falcor_dart.convert_path_key_to_integers;

import 'package:falcor_dart/src/types/range.dart';

onRange(List out, Range range) {
  out.add(range);
}

/**
 * @param {Number|String} key must be a number
 */
keyReduce(out, key, Range range) {
  if (!isNumber(key)) {
    return range;
  }

  key = +key;
  if (range) {
    if (key - 1 === range.to) {
      range.to = key;
    }

    else if (key + 1 === range.from) {
      range.from = key;
    }

    else {
      range = null;
    }
  }

  if (!range) {
    range = {to: key, from: key};
    out[out.length] = range;
  }
  /* eslint-enable no-param-reassign */

  return range;
}
