library falcor_dart.cache.optimize_path_set;

import 'package:falcor_dart/src/cache/follow_reference.dart';
import 'package:falcor_dart/src/path_utils/iterate_key_set.dart';
import 'package:falcor_dart/src/utils.dart';
import 'package:falcor_dart/src/types/sentinels.dart';
import 'package:falcor_dart/src/path_set.dart';

/// The fastest possible optimize of paths.
///
/// What it does:
/// - Any atom short-circuit / found value will be removed from the path.
/// - All paths will be exploded which means that collapse will need to be
///   ran afterwords.
/// - Any missing path will be optimized as much as possible.
List optimizePathSets(Map cache, List<PathSet> paths, int maxRefFollow) {
  var optimized = [];

  paths.forEach((path) {
    optimizePathSet(cache, cache, path, 0, optimized, [], maxRefFollow);
  });

  return optimized;
}

/// optimizes one pathSet at a time.
void optimizePathSet(cache, Map cacheRoot, pathSet, depth, List out,
    List optimizedPath, int maxRefFollow, [bool containsKey = true]) {

  // at missing, report optimized path.
  if (!containsKey) {
    out.add(catAndSlice(optimizedPath, pathSet, depth));
    return;
  }

  // If the reference is the last item in the path then do not
  // continue to search it.
  if ((containsKey && cache == null) || (cache is Sentinel && cache.isRef && depth == pathSet.length)) {
    return;
  }

  // all other sentinels are short circuited.
  // Or we found a primitive.
  if (cache is! Map || (cache is Sentinel && !cache.isRef)) {
    return;
  }

  var keySet = pathSet[depth];
  var nextDepth = depth + 1;
  var iteratorNote = {};
  var key, next, nextOptimized;

  key = iterateKeySet(keySet, iteratorNote);

  do {
    next = cache[key];
    var isDefined = cache.containsKey(key);
    var optimizedPathLength = optimizedPath.length;

    if (key != null) {
      optimizedPath.add(key);
    }

    if (next is Sentinel &&
        next.isRef &&
        nextDepth < pathSet.length) {
      var refResults = followReference(cacheRoot, next.value, maxRefFollow);
      next = refResults[0];
      if (next == null) {
        isDefined = false;
      }

      // must clone to avoid the mutation from above destroying the cache.
      nextOptimized = new List.from(refResults[1]);
    } else {
      nextOptimized = optimizedPath;
    }

    optimizePathSet(
        next, cacheRoot, pathSet, nextDepth, out, nextOptimized, maxRefFollow, isDefined);
    optimizedPath.length = optimizedPathLength;

    if (!iteratorNote['done']) {
      key = iterateKeySet(keySet, iteratorNote);
    }
  } while (!iteratorNote['done']);
}
