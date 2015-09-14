library falcor_dart.spread_paths;

import 'package:falcor_dart/src/path_utils/iterate_key_set.dart';
import 'package:falcor_dart/src/path_set.dart';

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
  if (key is Map) {
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
    if (currentPath.length == depth) {
      print('SUPER MUCH DDANGER, SETTING LENGTH OF LIST');
    }

    innerKey = iterateKeySet(key, iteratorNote);
  } while (!iteratorNote['done']);
}
