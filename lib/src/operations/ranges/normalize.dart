library falcor_dart.normalize;

import 'package:falcor_dart/src/types/range.dart';

/**
 * takes in a range and normalizes it to have a to / from
 */
normalize(Map range) {
  var from = range['from'] ?? 0;
  var to;
  if (range['to'] is num) {
    to = range['to'];
  } else {
    to = from + range.length - 1;
  }

  return new Range(from, to);
}
