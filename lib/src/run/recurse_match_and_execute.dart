library falcor_dart.recurse_match_and_execute;

import 'dart:async';
import 'package:falcor_dart/src/cache/optimize_path_set.dart';
import 'package:falcor_dart/src/operations/matcher.dart';
import 'package:falcor_dart/src/router.dart';
import 'package:falcor_dart/src/run/precedence/run_by_precedence.dart';
import 'package:falcor_dart/src/path_utils/collapse.dart';
import 'package:falcor_dart/src/cache/path_value_merge.dart';
import 'package:falcor_dart/src/utils.dart';
import 'package:falcor_dart/src/cache/jsong_merge.dart';

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
Future _recurseMatchAndExecute(Matcher match, actionRunner, List<List> paths,
    String method, Router routerInstance, jsongCache) async {
  var missing = [];
  var invalidated = [];
  var reportedPaths = [];
  var currentMethod = method;

  await Future.wait(paths.map((List nextPaths) async {
    if (nextPaths.isEmpty) {
      return [];
    }

    var matchedResults = match(currentMethod, nextPaths);

    if (matchedResults.matched.isEmpty) {;
      return [];
    }

    var matchedResult = matchedResults.matched;
    var results = await runByPrecedence(nextPaths, matchedResult, actionRunner);

    // Generate from the combined results the next requestable paths
    // and insert errors / values into the cache.
    return results.expand((results) {
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
        return next['value'].concat(suffix);
      });

      // Alters the behavior of the expand
      messages.forEach((message) {
        // mutates the method type for the matcher
        if (message['method']) {
          currentMethod = message['method'];
        }

        // Mutates the nextPaths and adds any additionalPaths
        else if (message['additionalPath']) {
          var path = message['additionalPath'];
          pathsToExpand.add(path);
          reportedPaths.add(path);
        }

        // Any invalidations that come down from a call
        else if (message['invalidations']) {
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
      return pathsToExpand;
    }).toList();
  }));

  // Each pathSet (some form of collapsed path) need to be sent
  // independently.  for each collapsed pathSet will, if producing
  // refs, be the highest likelihood of collapsibility.

  return {
    'missing': missing,
    'invalidated': invalidated,
    'jsonGraph': jsongCache,
    'reportedPaths': reportedPaths
  };
}

/**
 * takes the response from an action and merges it into the
 * cache.  Anything that is an invalidation will be added to
 * the first index of the return value, and the inserted refs
 * are the second index of the return value.  The third index
 * of the return value is messages from the action handlers
 *
 * @param {Object} cache
 * @param {Array} jsongOrPVs
 */
mergeCacheAndGatherRefsAndInvalidations(cache, jsongOrPVs) {
  var references = [];
  var len = -1;
  var invalidations = [];
  var messages = [];
  var values = [];

  jsongOrPVs.forEach((jsongOrPV) {
    var refsAndValues = {};

    if (isMessage(jsongOrPV)) {
      messages[messages.length] = jsongOrPV;
    } else if (isJSONG(jsongOrPV)) {
      refsAndValues = jsongMerge(cache, jsongOrPV);
    }

    // Last option are path values.
    else {
      refsAndValues = pathValueMerge(cache, jsongOrPV);
    }

    var refs = refsAndValues['references'];
    var vals = refsAndValues['values'];
    var invs = refsAndValues['invalidations'];

    if (vals is List && vals.isNotEmpty) {
      values.addAll(vals);
    }

    if (invs is List && invs.isNotEmpty) {
      invalidations.addAll(invs);
    }

    if (refs != null && refs.isNotEmpty) {
      refs.forEach((ref) {
        references[++len] = ref;
      });
    }
  });

  return {
    'invalidations': invalidations,
    'references': references,
    'messages': messages,
    'values': values
  };
}
