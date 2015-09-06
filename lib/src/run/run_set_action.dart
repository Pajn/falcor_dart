library falcor_dart.run_set_action;

import 'package:falcor_dart/src/cache/get_value.dart';
import 'package:falcor_dart/src/run/run_get_action.dart';
import 'package:falcor_dart/src/router.dart';
import 'package:falcor_dart/src/cache/optimize_path_set.dart';
import 'package:falcor_dart/src/path_utils/has_intersection.dart';
import 'package:falcor_dart/src/cache/path_value_merge.dart';

outerRunSetAction(Router routerInstance, modelContext, Map jsongCache) {
  return (matchAndPath) =>
      runSetAction(routerInstance, modelContext, matchAndPath, jsongCache);
}

runSetAction(Router routerInstance, jsongMessage, matchAndPath, [Map jsongCache]) {
  var match = matchAndPath.match;
  var out;
  var arg = matchAndPath.path;

  // We are at out destination.  Its time to get out
  // the pathValues from the
  if (match.isSet) {
    var paths = spreadPaths(jsongMessage.paths);

    // We have to ensure that the paths maps in order
    // to the optimized paths array.
    var optimizedPaths = paths
        // Optimizes each path.
        .map((path) => optimizePathSets(
            jsongCache, [path], routerInstance.maxRefFollow)[0])
        // only includes the paths from the set that intersect
        // the virtual path
        .filter((path) => hasIntersection(path, match.virtual));

    // Constructs the json that is the set request virtual path.
    arg = paths.reduce((json, path, i) {
      pathValueMerge(json, {
        'path': optimizedPaths[i],
        'value': getValue(jsongMessage.jsonGraph, path)
      });
      return json;
    }, {});
  }
  out = match.action.call(routerInstance, arg);
  out = outputToStream(out);

  return authorize(routerInstance, match, out)
      .materialize()
      .filter((note) => note.kind != 'C')
      .map(noteToJsongOrPV(matchAndPath));
}
