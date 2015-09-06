library falcor_dart.has_intersection;

import 'package:falcor_dart/src/path_utils/iterate_key_set.dart';
import 'package:falcor_dart/src/types/range.dart';

/**
 * Tests to see if the intersection should be stripped from the
 * total paths.  The only way this happens currently is if the entirety
 * of the path is contained in the tree.
 * @private
 */
hasIntersection(Map tree, List path, int depth) {
  var current = tree;
  var intersects = true;

  // Continue iteratively going down a path until a complex key is
  // encountered, then recurse.
  for (;intersects && depth < path.length; ++depth) {
    var key = path[depth];

    // We have to iterate key set
    if (key is Map || key is Range || key is List) {
      var note = {};
      var innerKey = iterateKeySet(key, note);
      var nextDepth = depth + 1;

      // Loop through the innerKeys setting the intersects flag
      // to each result.  Break out on false.
      do {
        intersects = current.containsKey(innerKey);
        var next = current[innerKey];

        if (intersects) {
          intersects = hasIntersection(next, path, nextDepth);
        }
        innerKey = iterateKeySet(key, note);
      } while (intersects && !note['done']);

      // Since we recursed, we shall not pass any further!
      break;
    }

    // Its a simple key, just move forward with the testing.
    intersects = current.containsKey(key);
    current = current[key];
  }

  return intersects;
}
