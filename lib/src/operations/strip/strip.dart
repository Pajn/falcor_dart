library falcor_dart.strip;

import 'package:falcor_dart/src/operations/strip/strip_from_array.dart';
import 'package:falcor_dart/src/operations/strip/strip_from_range.dart';

/**
 *  Takes a virtual atom and the matched atom and returns an
 * array of results that is relative complement with matchedAtom
 * as the rhs.  I believe the proper set syntax is virutalAtom \ matchedAtom.
 *
 * 1) An assumption made is that the matched atom and virtual atom have
 * an intersection.  This makes the algorithm easier since if the matched
 * atom is a primitive and the virtual atom is an object
 * then there is no relative complement to create.  This also means if
 * the direct equality test fails and matchedAtom is not an object
 * then virtualAtom is an object.  The inverse applies.
 *
 *
 * @param {String|Number|Array|Object} matchedAtom
 * @param {String|Number|Array|Object} virtualAtom
 * @return {Array} the tuple of what was matched and the relative complenment.
 */
List strip(matchedAtom, virtualAtom) {
  var relativeComplement = [];
  var matchedResults;

  // Lets assume they are not objects  This covers the
  // string / number cases.
  if (matchedAtom == virtualAtom ||
      matchedAtom.toString() == virtualAtom.toString()) {
    matchedResults = [matchedAtom];
  }

  // See function comment 1)
  else if (matchedAtom is! Map && matchedAtom is! List) {
    matchedResults = [matchedAtom];
  }

  // Its a complex object set potentially.  Let the
  // subroutines handle the cases.
  else {
    var results;

    // The matchedAtom needs to reduced to everything that is not in
    // the virtualAtom.
    if (matchedAtom is List) {
      results = stripFromArray(virtualAtom, matchedAtom);
      matchedResults = results[0];
      relativeComplement = results[1];
    } else {
      results = stripFromRange(virtualAtom, matchedAtom);
      matchedResults = results[0];
      relativeComplement = results[1];
    }
  }

  if (matchedResults.length == 1) {
    matchedResults = matchedResults[0];
  }

  return [matchedResults, relativeComplement];
}
