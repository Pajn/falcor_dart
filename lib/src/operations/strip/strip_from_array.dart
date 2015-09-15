library falcor_dart.strip_from_array;

import 'package:falcor_dart/src/keys.dart';
import 'package:falcor_dart/src/types/range.dart';
import 'package:falcor_dart/src/operations/strip/strip_from_range.dart';

/**
 * Takes a string, number, or RoutedToken and removes it from
 * the array.  The results are the relative complement of what
 * remains in the array.
 *
 * Don't forget: There was an intersection test performed but
 * since we recurse over arrays, we will get elements that do
 * not intersect.
 *
 * Another one is if its a routed token and a ranged array then
 * no work needs to be done as integers, ranges, and keys match
 * that token set.
 *
 * One more note.  When toStrip is an array, we simply recurse
 * over each key.  Else it requires a lot more logic.
 *
 * @param {Array|String|Number|RoutedToken} toStrip
 * @param {Array} array
 * @return {Array} the relative complement.
 */
List stripFromArray(toStrip, List array) {
  var complement;
  var matches = [];
  var isRangedArray = array[0] is Range;
  var isNumber = toStrip is num;
  var isString = toStrip is String;
  var isRoutedToken = !isNumber && !isString;
  var routeType = toStrip is Map ? toStrip['type'] : null;
  var isKeys = routeType == Keys.keys;

  // The early break case.  If its a key, then there is never a
  // relative complement.
  if (isKeys) {
    complement = [];
    matches = array;
  }

  // Recurse over all the keys of the array.
  else if (toStrip is List) {
    var currentArray = array;
    toStrip.forEach((atom) {
      var results = stripFromArray(atom, currentArray);
      if (results[0] != null) {
        matches.addAll(results[0]);
      }
      currentArray = results[1];
    });
    complement = currentArray;
  }

  // The simple case, remove only the matching element from array.
  else if (!isRangedArray && !isRoutedToken) {
    matches = [toStrip];
    complement = array.where((x) => toStrip != x).toList();
  }

  // 1: from comments above
  else if (isRangedArray && !isRoutedToken) {
    complement = array.fold([], (comp, range) {
      var results = stripFromRange(toStrip, range);
      if (results[0] != null) {
        matches.addAll(results[0]);
      }
      return comp..addAll(results[1]);
    });
  }

  // Strips elements based on routed token type.
  // We already matched keys above, so we only need to strip numbers.
  else if (!isRangedArray && isRoutedToken) {
    complement = array.where((el) {
      if (el is num) {
        matches.add(el);
        return false;
      }
      return true;
    }).toList();
  }

  // The final complement is rangedArray with a routedToken,
  // relative complement is always empty.
  else {
    complement = [];
    matches = array;
  }

  return [matches, complement];
}
