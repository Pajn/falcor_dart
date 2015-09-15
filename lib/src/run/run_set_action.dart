library falcor_dart.run_set_action;

import 'package:falcor_dart/src/cache/get_value.dart';
import 'package:falcor_dart/src/run/run_get_action.dart';
import 'package:falcor_dart/src/router.dart';
import 'package:falcor_dart/src/cache/optimize_path_set.dart';
import 'package:falcor_dart/src/path_utils/has_intersection.dart';
import 'package:falcor_dart/src/cache/path_value_merge.dart';
import 'package:falcor_dart/src/run/spread_paths.dart';
import 'package:falcor_dart/src/cache/jsong_merge.dart';

runSetAction(Router routerInstance, modelContext, Map jsongCache) {
  return (matchAndPath) =>
      innerRunSetAction(routerInstance, modelContext, matchAndPath, jsongCache);
}

innerRunSetAction(Router routerInstance, jsongMessage, matchAndPath,
    [Map jsongCache]) async {
  var match = matchAndPath['match'];
  var out;
  var arg = matchAndPath['path'];

  // We are at out destination.  Its time to get out
  // the pathValues from the
  if (match['isSet']) {
    var paths = spreadPaths(jsongMessage['paths']);

    // We have to ensure that the paths maps in order
    // to the optimized paths array.
    var optimizedPathsAndPaths = paths
        // Optimizes each path.
        .map((path) {
      var optimized = optimizePathSets(jsongCache, [path], routerInstance.maxRefFollow + 2);
      return [
        optimized.isNotEmpty ? optimized[0] : null,
              path
            ];
    })
        // only includes the paths from the set that intersect
        // the virtual path
        .where((path) => path[0] != null &&
            hasIntersection(path[0].asMap(), match['virtual']))
        .toList();
    var optimizedPaths = optimizedPathsAndPaths.map((opp) {
      return opp[0];
    }).toList();
    var subSetPaths = optimizedPathsAndPaths.map((opp) {
      return opp[1];
    }).toList();
    var i = 0;
    var tmpJsonGraph = subSetPaths.fold({}, (json, path) {
      pathValueMerge(json, {
        'path': optimizedPaths[i],
        'value': getValue(jsongMessage['jsonGraph'], path)
      });
      i += 1;
      return json;
    });

    // Takes the temporary JSONGraph, attaches only the matched paths
    // then creates the subset json and assigns it to the argument to
    // the set function.
    var subJsonGraphEnv = {
      'jsonGraph': tmpJsonGraph,
      'paths': [match['requested']],
    };
    arg = {};
    jsongMerge(arg, subJsonGraphEnv);
  }

  try {
    out = await match['action'](arg);
    if (out is! Iterable) {
      out = [out];
    }

    return out.map(noteToJsongOrPV(matchAndPath));
  } catch (error) {
    rethrow;
    return [convertNoteToJsongOrPV(matchAndPath, error, error: true)];
  }
}
