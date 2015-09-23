library falcor_dart.spread_paths;

import 'package:falcor_dart/src/path_utils/iterate_key_set.dart';
import 'package:falcor_dart/src/path_set.dart';
import 'package:falcor_dart/src/types/range.dart';

/**
 * Takes in a ptahSet and will create a set of simple paths.
 * @param {Array} paths
 */
List<PathSet> spreadPaths(paths) {
  var allPaths = [];
  paths.forEach((x) {
    _spread(x, 0, allPaths);
  });

  return allPaths;
}

void _spread(PathSet pathSet, depth, List<PathSet> out, [PathSet currentPath]) {
  currentPath ??= new PathSet();

  if (depth == pathSet.length) {
    out.add(new PathSet.from(currentPath));
    return;
  }

  // Simple case
  var key = pathSet[depth];
  if (key is! Map && key is! List && key is! Range) {
    currentPath[depth] = key;
    _spread(pathSet, depth + 1, out, currentPath);
    return;
  }

  // complex key.
  var iteratorNote = {};
  var innerKey = iterateKeySet(key, iteratorNote);
  do {
    // spreads the paths
    currentPath.add(innerKey);
    _spread(pathSet, depth + 1, out, currentPath);
    currentPath.length = depth;

    innerKey = iterateKeySet(key, iteratorNote);
  } while (!iteratorNote['done']);
}
