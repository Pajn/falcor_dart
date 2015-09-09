library falcor_dart.pluck_integers;

import 'package:falcor_dart/src/utils.dart';

/**
 * plucks any integers from the path key.  Makes no effort
 * to convert the key into any specific format.
 */
List<int> pluckIntegers(keySet) {
  var ints = [];

  if (keySet is Map || keySet is List) {
    if (keySet is List) {
      keySet.forEach((key) {
        // Range case
        if (key is Map) {
          ints.add(key);
        } else if (isNumeric(key)) {
          ints.add(parseNum(key));
        }
      });
    }
    // Range case
    else {
      ints.add(keySet);
    }
  } else if (isNumeric(keySet)) {
    ints.add(parseNum(keySet));
  }

  return ints;
}
