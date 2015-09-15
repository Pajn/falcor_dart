library falcor_dart.recurse_match_and_execute;

import 'dart:async';
import 'package:falcor_dart/src/cache/optimize_path_set.dart';
import 'package:falcor_dart/src/operations/matcher.dart';
import 'package:falcor_dart/src/router.dart';
import 'package:falcor_dart/src/run/precedence/run_by_precedence.dart';
import 'package:falcor_dart/src/path_utils/collapse.dart';
import 'package:falcor_dart/src/path_set.dart';
import 'package:falcor_dart/src/run/merge_cache_and_gather_refs_and_invalidations.dart';

/**
 * The recurse and match function will async recurse as long as
 * there are still more paths to be executed.  The match function
 * will return a set of objects that have how much of the path that
 * is matched.  If there still is more, denoted by suffixes,
 * paths to be matched then the recurser will keep running.
 */
Future recurseMatchAndExecute(
    Matcher match, actionRunner, paths, method, routerInstance, jsongCache) {
  return _recurseMatchAndExecute(
      match, actionRunner, paths, method, routerInstance, jsongCache);
}

/**
 * performs the actual recursing
 */
Future _recurseMatchAndExecute(Matcher match, actionRunner, List<PathSet> paths,
    String method, Router routerInstance, jsongCache) async {
  var missing = [];
  var invalidated = [];
  var reportedPaths = [];
  var currentMethod = method;

  var toExecute = new List.from(paths);

  while (toExecute.isNotEmpty) {
    var nextPaths = toExecute.removeAt(0);
    if (nextPaths.isEmpty) continue;

    var matchedResults = match(currentMethod, nextPaths);

    if (matchedResults.matched.isEmpty) continue;

    var matchedResult = matchedResults.matched;
    var results = await runByPrecedence(nextPaths, matchedResult, actionRunner);

    // Generate from the combined results the next requestable paths
    // and insert errors / values into the cache.
    results.forEach((results) {
      var value = results['value'];
      var suffix = results['match']['suffix'];

      if (value is! List) {
        value = [value];
      }
      var invsRefsAndValues =
      mergeCacheAndGatherRefsAndInvalidations(jsongCache, value);
      var invalidations = invsRefsAndValues['invalidations'];
      var messages = invsRefsAndValues['messages'];
      var pathsToExpand = [];

      if (suffix.length > 0) {
        pathsToExpand = invsRefsAndValues['references'];
      }

      invalidated.addAll(invalidations);

      // Merges the remaining suffix with remaining nextPaths
      pathsToExpand = pathsToExpand.map((next) {
        var pathSet = new PathSet();
        pathSet.addAll(next['value']);
        pathSet.addAll(suffix);
        return pathSet;
      }).toList();

      // Alters the behavior of the expand
      messages.forEach((message) {
        // mutates the method type for the matcher
        if (message['method'] != null) {
          currentMethod = message['method'];
        }

        // Mutates the nextPaths and adds any additionalPaths
        else if (message['additionalPath'] != null) {
          var path = message['additionalPath'];
          pathsToExpand.add(path);
          reportedPaths.add(path);
        }

        // Any invalidations that come down from a call
        else if (message['invalidations'] != null) {
          invalidated.addAll(message['invalidations']);
        }
      });

      // Explodes and collapse the tree to remove
      // redundants and get optimized next set of
      // paths to evaluate.
      pathsToExpand = optimizePathSets(
          jsongCache, pathsToExpand.toList(), routerInstance.maxRefFollow);

      if (pathsToExpand.isNotEmpty) {
        pathsToExpand = collapse(pathsToExpand);
      }

      missing.addAll(matchedResults.missingPaths);

      toExecute.addAll(pathsToExpand);
    });
  }

  // Each pathSet (some form of collapsed path) need to be sent
  // independently.  for each collapsed pathSet will, if producing
  // refs, be the highest likelihood of collapsibility.

//  print('returns');
//  print(jsongCache);

  return {
    'missing': missing,
    'invalidated': invalidated,
    'jsonGraph': jsongCache,
    'reportedPaths': reportedPaths
  };
}
