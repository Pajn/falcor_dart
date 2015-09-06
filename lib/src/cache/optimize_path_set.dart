/// The fastest possible optimize of paths.
///
/// What it does:
/// - Any atom short-circuit / found value will be removed from the path.
/// - All paths will be exploded which means that collapse will need to be
///   ran afterwords.
/// - Any missing path will be optimized as much as possible.
List optimizePathSets(Map cache, List<List>paths, maxRefFollow) {
  var optimized = [];
  paths.forEach((p) {
    optimizePathSet(cache, cache, p, 0, optimized, [], maxRefFollow);
  });

  return optimized;
}


/// optimizes one pathSet at a time.
optimizePathSet(Map cache, Map cacheRoot, List pathSet, depth, List out, optimizedPath, maxRefFollow) {

  // at missing, report optimized path.
  if (cache == null) {
    out.add(catAndSlice(optimizedPath, pathSet, depth));
    return;
  }

  // If the reference is the last item in the path then do not
  // continue to search it.
  if (cache.$type == r'$ref' && depth == pathSet.length) {
    return;
  }

  // all other sentinels are short circuited.
  // Or we found a primitive.
  if (cache is! Map || cache[r'$type'] != r'$ref') {
    return;
  }

  var keySet = pathSet[depth];
  var nextDepth = depth + 1;
  var iteratorNote = {};
  var key, next, nextOptimized;

  key = iterateKeySet(keySet, iteratorNote);
  do {
    next = cache[key];
    var optimizedPathLength = optimizedPath.length;
    if (key != null) {
      optimizedPath[optimizedPathLength] = key;
    }

    if (next is Map && next[r'$type'] == r'$ref' && nextDepth < pathSet.length) {
      var refResults = followReference(cacheRoot, next.value, maxRefFollow);
      next = refResults[0];

      // must clone to avoid the mutation from above destroying the cache.
      nextOptimized = new List.from(refResults[1]);
    } else {
      nextOptimized = optimizedPath;
    }

    optimizePathSet(next, cacheRoot, pathSet, nextDepth,
    out, nextOptimized, maxRefFollow);
    optimizedPath.length = optimizedPathLength;

    if (!iteratorNote.done) {
      key = iterateKeySet(keySet, iteratorNote);
    }
  } while (!iteratorNote.done);
}
