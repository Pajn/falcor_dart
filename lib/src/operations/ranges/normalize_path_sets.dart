library falcor_dart.normalize_path_sets;

import 'package:falcor_dart/src/operations/ranges/normalize.dart';
import 'package:falcor_dart/src/path_set.dart';

/**
 * warning:  This mutates the array of arrays.
 * It only converts the ranges to properly normalized ranges
 * so the rest of the algos do not have to consider it.
 */
List<PathSet> normalizePathSets(List path) {
  for (var i = 0; i < path.length; ++i) {
    var key = path[i];

    // the algo becomes very simple if done recursively.  If
    // speed is needed, this is an easy optimization to make.
    if (key is List) {
      var pathSet = new PathSet();
      pathSet.pathParts.addAll(normalizePathSets(key));
      path[i] = pathSet;
    } else if (key is Map) {
      path[i] = normalize(key);
    }
  }
  return path;
}
