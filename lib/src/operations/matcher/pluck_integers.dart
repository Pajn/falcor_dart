library falcor_dart.pluck_integers;

import 'package:falcor_dart/src/utils.dart';
import 'package:falcor_dart/src/types/range.dart';

/**
 * plucks any integers from the path key.  Makes no effort
 * to convert the key into any specific format.
 */
List<int> pluckIntegers(keySet) {
  var ints = [];

  if (keySet is List) {
    keySet.forEach((key) {
      // Range case
      if (key is Map) {
        ints.add(key);
      } else if (isNumeric(key)) {
        ints.add(parseNum(key));
      }
    });
  } else if (keySet is Range) {
    ints.addAll(keySet.toList());
  } else if (isNumeric(keySet)) {
    ints.add(parseNum(keySet));
  }

  return ints;
}
