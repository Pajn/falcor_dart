library falcor_dart.strip_from_range;

import 'package:falcor_dart/src/types/range.dart';
import 'package:falcor_dart/src/utils.dart';

/**
 *  Takes the first argument, toStrip, and strips it from
 * the range.  The output is an array of ranges that represents
 * the remaining ranges (relative complement)
 *
 * One note.  When toStrip is an array, we simply recurse
 * over each key.  Else it requires a lot more logic.
 *
 * Since we recurse array keys we are not guaranteed that each strip
 * item coming in is a string integer.  That is why we are doing an isNaN
 * check. consider: {from: 0, to: 1} and [0, 'one'] intersect at 0, but will
 * get 'one' fed into stripFromRange.
 *
 * @param {Array|String|Number|Object} argToStrip can be a string, number,
 * or a routed token.  Cannot be a range itself.
 * @param {Range} range
 * @return {Array.<Range>} The relative complement.
 */
stripFromRange(argToStrip, Range range) {
  var ranges = [];
  var matches = [];
  var toStrip = argToStrip;
  // TODO: More than likely a bug around numbers and stripping
  if (isNumeric(toStrip)) {
    toStrip = parseNum(toStrip);
  }

  // Strip out NaNs
  if (toStrip is String) {
    ranges = [range];
  }

  else if (toStrip is List) {
    var currenRanges = [range];
    toStrip.forEach((atom) {
      var nextRanges = [];
      currenRanges.forEach((currentRename) {
      var matchAndComplement = stripFromRange(atom, currentRename);
      if (matchAndComplement[0] != null) {
      matches.addAll(matchAndComplement[0]);
      }

      nextRanges.addAll(matchAndComplement[1]);
    });
    currenRanges = nextRanges;
    });

    ranges = currenRanges;
  }

  // The simple case, its just a number.
  else if (toStrip is num) {

    if (range.from < toStrip && toStrip < range.to) {
      ranges[0] = new Range(range.from, toStrip - 1);
      ranges[1] = new Range(toStrip + 1, range.to);
      matches = [toStrip];
    }

    // In case its a 0 length array.
    // Even though this assignment is redundant, its point is
    // to capture the intention.
    else if (range.from == toStrip && range.to == toStrip) {
      ranges = [];
      matches = [toStrip];
    }

    else if (range.from == toStrip) {
      ranges[0] = new Range(toStrip + 1, range.to);
      matches = [toStrip];
    }

    else if (range.to == toStrip) {
      ranges[0] = new Range(range.from, toStrip - 1);
      matches = [toStrip];
    }

    // return the range if no intersection.
    else {
      ranges = [range];
    }
  }

  // Its a routed token.  Everything is matched.
  else {
    matches = range.toList();
  }

  // If this is a routedToken (Object) then it will match the entire
  // range since its integers, keys, and ranges.
  return [matches, ranges];
}
