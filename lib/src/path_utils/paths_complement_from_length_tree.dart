library falcor_dart.paths_complement_from_lentgh_tree.dart;

import 'package:falcor_dart/src/path_utils/has_intersection.dart';

/**
 * Compares the paths passed in with the tree.  Any of the paths that are in
 * the tree will be stripped from the paths.
 *
 * **Does not mutate** the incoming paths object.
 * **Proper subset** only matching.
 *
 * @param {Array} paths - A list of paths (complex or simple) to strip the
 * intersection
 * @param {Object} tree -
 * @public
 */
List pathsComplementFromLengthTree(List paths, tree) {
  var out = [];

  for (var path in paths) {
    // If this does not intersect then add it to the output.
    if (!hasIntersection(tree[path.length], path, 0)) {
      out.add(path);
    }
  }
  return out;
}
