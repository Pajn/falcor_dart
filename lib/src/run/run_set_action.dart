library falcor_dart.run_set_action;

import 'package:falcor_dart/src/cache/get_value.dart';
import 'package:falcor_dart/src/run/run_get_action.dart';
import 'package:falcor_dart/src/router.dart';
import 'package:falcor_dart/src/cache/optimize_path_set.dart';
import 'package:falcor_dart/src/path_utils/has_intersection.dart';
import 'package:falcor_dart/src/cache/path_value_merge.dart';
import 'package:falcor_dart/src/run/spread_paths.dart';

runSetAction(Router routerInstance, modelContext, Map jsongCache) {
  return (matchAndPath) =>
      innerRunSetAction(routerInstance, modelContext, matchAndPath, jsongCache);
}

innerRunSetAction(Router routerInstance, jsongMessage, matchAndPath, [Map jsongCache]) async {
  var match = matchAndPath['match'];
  var out;
  var arg = matchAndPath['path'];

  // We are at out destination.  Its time to get out
  // the pathValues from the
  if (match['isSet']) {
    var paths = spreadPaths(jsongMessage['paths']);

    // We have to ensure that the paths maps in order
    // to the optimized paths array.
    var optimizedPaths = paths
        // Optimizes each path.
        .map((path) => optimizePathSets(
            jsongCache, [path], routerInstance.maxRefFollow)[0])
        // only includes the paths from the set that intersect
        // the virtual path
        .where((path) => hasIntersection(path.asMap(), match['virtual']))
        .toList();

    // Constructs the json that is the set request virtual path.
    var i = 0;
    arg = paths.fold({}, (json, path) {
      pathValueMerge(json, {
        'path': optimizedPaths[i],
        'value': getValue(jsongMessage['jsonGraph'], path)
      });
      i += 1;
      return json;
    });
  }

  try {
    out = await match['action'](arg);

    return out
        .map(noteToJsongOrPV(matchAndPath));
  } catch(error) {
    return [convertNoteToJsongOrPV(matchAndPath, error, error: true)];
  }
}
