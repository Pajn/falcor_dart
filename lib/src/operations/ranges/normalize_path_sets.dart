library falcor_dart.normalize_path_sets;

/**
 * warning:  This mutates the array of arrays.
 * It only converts the ranges to properly normalized ranges
 * so the rest of the algos do not have to consider it.
 */
normalizePathSets(path) {
  path.forEach((key, i) {
    // the algo becomes very simple if done recursively.  If
    // speed is needed, this is an easy optimization to make.
    if (key is List) {
      normalizePathSets(key);
    } else if (key is Map) {
      path[i] = normalize(path[i]);
    }
  });
  return path;
}
