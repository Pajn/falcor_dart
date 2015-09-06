library falcor_dart.router;

import 'package:falcor_dart/src/cache/optimize_path_set.dart';
import 'package:falcor_dart/src/run/recurse_match_and_execute.dart';

class Router {
  final maxRefFollow = 50;

  get(paths) {
    var jsongCache = {};
    var action = runGetAction(this, jsongCache);
    var normPS = normalizePathSets(paths);

    return run(this._matcher, action, normPS, get, this, jsongCache)
      .map((jsongEnv) => materializeMissing(this, paths, jsongEnv));
  }

  set(jsong) {
    // TODO: Remove the modelContext and replace with just jsongEnv
    // when http://github.com/Netflix/falcor-router/issues/24 is addressed
    var jsongCache = {};
    var action = runSetAction(this, jsong, jsongCache);

    return run(this._matcher, action, jsong.paths, set, this, jsongCache)
      .map((jsongEnv) => materializeMissing(this, jsong.paths, jsongEnv));
  }

  call(callPath, args, suffixes, paths) {
    var jsongCache = {};
    var action = runCallAction(this, callPath, args,
    suffixes, paths, jsongCache);
    var callPaths = [callPath];

    return run(this._matcher, action, callPaths, call, this, jsongCache)
      .map((jsongResult) {
      var reportedPaths = jsongResult.reportedPaths;
      var jsongEnv = materializeMissing(this, callPaths, jsongResult, {
        r'$type': r'$atom',
        r'$expires': 0
      });
      materializeMissing(this, reportedPaths, jsongResult);


      if (reportedPaths.length) {
        jsongEnv.paths = reportedPaths;
      } else {
        jsongEnv.paths = [];
      }

      jsongEnv.paths.push(callPath);
      var invalidated = jsongResult.invalidated;
      if (invalidated && invalidated.length) {
        jsongEnv.invalidations = invalidated;
      }
      jsongEnv.paths = collapse(jsongEnv.paths);
      return jsongEnv;
    });
  }
}

run(matcherFn, actionRunner, paths, method,
    routerInstance, jsongCache) {
  return recurseMatchAndExecute(
      matcherFn, actionRunner, paths, method, routerInstance, jsongCache);
}

materializeMissing(Router router, paths, jsongEnv, [missingAtom = const {r'$type': r'$atom'}]) {
  var jsonGraph = jsongEnv.jsonGraph;

  // Optimizes the pathSets from the jsong then
  // inserts atoms of undefined.
  optimizePathSets(jsonGraph, paths, router.maxRefFollow).forEach((optMissingPath) {
    pathValueMerge(jsonGraph, {
      'path': optMissingPath,
      'value': missingAtom
    });
  });

  return {'jsonGraph': jsonGraph};
}
