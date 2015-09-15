library falcor_dart.router;

import 'dart:async';
import 'package:falcor_dart/src/cache/optimize_path_set.dart';
import 'package:falcor_dart/src/run/recurse_match_and_execute.dart';
import 'package:falcor_dart/src/run/run_get_action.dart';
import 'package:falcor_dart/src/run/run_set_action.dart';
import 'package:falcor_dart/src/path_utils/collapse.dart';
import 'package:falcor_dart/src/cache/path_value_merge.dart';
import 'package:falcor_dart/src/operations/matcher.dart';
import 'package:falcor_dart/src/parse_tree/parse_tree.dart';
import 'package:falcor_dart/src/run/run_call_action.dart';
import 'package:falcor_dart/src/operations/ranges/normalize_path_sets.dart';
import 'package:falcor_dart/src/types/sentinels.dart';

class Router {
  List<Map> _routes;
  var _rst;
  Matcher _matcher;
  final maxRefFollow = 50;

  Router(this._routes) {
    _rst = parseTree(_routes);
    _matcher = matcher(this._rst);
  }

  Future get(List paths) {
    var jsongCache = {};
    var action = runGetAction(this, jsongCache);
    var normPS = normalizePathSets(paths);

    return run(this._matcher, action, normPS, 'get', this, jsongCache)
        .then((jsongEnv) => materializeMissing(this, paths, jsongEnv));
  }

  Future set(Map jsong) async {
    // TODO: Remove the modelContext and replace with just jsongEnv
    // when http://github.com/Netflix/falcor-router/issues/24 is addressed
    var jsongCache = {};
    var action = runSetAction(this, jsong, jsongCache);
    var normPS = normalizePathSets(jsong['paths']);

    var jsongEnv = await run(this._matcher, action, normPS, 'set', this, jsongCache);

    return materializeMissing(this, jsong['paths'], jsongEnv);
  }

  call(List callPath, List args, [List suffixes, List paths]) async {
    var jsongCache = {};
    var action =
        runCallAction(this, callPath, args, suffixes, paths, jsongCache);
    var callPaths = normalizePathSets([callPath]);

    var jsongResult =
        await run(this._matcher, action, callPaths, 'call', this, jsongCache);
    var reportedPaths = jsongResult['reportedPaths'];
    var jsongEnv = materializeMissing(this, reportedPaths, jsongResult);

    if (reportedPaths.isNotEmpty) {
      jsongEnv['paths'] = reportedPaths;
    } else {
      jsongEnv['paths'] = [];
    }

    var invalidated = jsongResult['invalidated'];
    if (invalidated != null && invalidated.isNotEmpty) {
      jsongEnv['invalidated'] = invalidated;
    }
    jsongEnv['paths'] = collapse(jsongEnv['paths']);
    return jsongEnv;
  }
}

Future<Map> run(
    matcherFn, actionRunner, paths, method, routerInstance, jsongCache) {
  return recurseMatchAndExecute(
      matcherFn, actionRunner, paths, method, routerInstance, jsongCache);
}

materializeMissing(Router router, paths, jsongEnv, [missingAtom]) {
  missingAtom ??= $atom(null);
  var jsonGraph = jsongEnv['jsonGraph'];

  // Optimizes the pathSets from the jsong then
  // inserts atoms of undefined.

  optimizePathSets(jsonGraph, paths, router.maxRefFollow)
      .forEach((optMissingPath) {
    pathValueMerge(jsonGraph, {'path': optMissingPath, 'value': missingAtom,});
  });

  return {'jsonGraph': jsonGraph};
}
