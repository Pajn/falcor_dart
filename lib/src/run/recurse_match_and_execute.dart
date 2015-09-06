library falcor_dart.recurse_match_and_execute;

import 'dart:async';
import 'package:falcor_dart/src/cache/optimize_path_set.dart';
import 'package:falcor_dart/src/operations/matcher.dart';
import 'package:falcor_dart/src/router.dart';
import 'package:falcor_dart/src/run/precedence/run_by_precedence.dart';

/**
 * The recurse and match function will async recurse as long as
 * there are still more paths to be executed.  The match function
 * will return a set of objects that have how much of the path that
 * is matched.  If there still is more, denoted by suffixes,
 * paths to be matched then the recurser will keep running.
 */
Future recurseMatchAndExecute(Matcher match, actionRunner, paths, method, routerInstance, jsongCache) {
  return _recurseMatchAndExecute(
      match, actionRunner, paths,
      method, routerInstance, jsongCache);
}

/**
 * performs the actual recursing
 */
Future _recurseMatchAndExecute(
    Matcher match, actionRunner, List<List> paths,
    String method, Router routerInstance, jsongCache) {
  var missing = [];
  var invalidated = [];
  var reportedPaths = [];
  var currentMethod = method;

  return new Stream

  // Each pathSet (some form of collapsed path) need to be sent
  // independently.  for each collapsed pathSet will, if producing
  // refs, be the highest likelihood of collapsibility.
  .fromIterable(paths)
  .asyncExpand((List nextPaths) {
    if (nextPaths.isEmpty) {
      return new Stream.fromIterable(nextPaths);
    }

    var matchedResults = match(currentMethod, nextPaths);

    if (matchedResults.matched.isEmpty) {
      return new Stream.fromIterable(matchedResults.matched);
    }

    var matchedResult = matchedResults.matched;
    return runByPrecedence(nextPaths, matchedResult, actionRunner)

      // Generate from the combined results the next requestable paths
      // and insert errors / values into the cache.
      .expand((results) {
        var value = results.value;
        var suffix = results.match.suffix;

        if (value is! List) {
          value = [value];
        }
        var invsRefsAndValues = mCGRI(jsongCache, value);
        var invalidations = invsRefsAndValues.invalidations;
        var messages = invsRefsAndValues.messages;
        var pathsToExpand = [];

        if (suffix.length > 0) {
          pathsToExpand = invsRefsAndValues.references;
        }

        invalidations.forEach((invalidation) {
          invalidated[invalidated.length] = invalidation;
        });

        // Merges the remaining suffix with remaining nextPaths
        pathsToExpand = pathsToExpand.map((next) {
          return next.value.concat(suffix);
        });

        // Alters the behavior of the expand
        messages.forEach((message) {
          // mutates the method type for the matcher
          if (message.method) {
            currentMethod = message.method;
          }

          // Mutates the nextPaths and adds any additionalPaths
          else if (message.additionalPath) {
            var path = message.additionalPath;
            pathsToExpand[pathsToExpand.length] = path;
            reportedPaths[reportedPaths.length] = path;
          }

          // Any invalidations that come down from a call
          else if (message.invalidations) {
            message.
            invalidations.
            forEach((invalidation) {
              invalidated.push(invalidation);
            });
          }
        });

        // Explodes and collapse the tree to remove
        // redundants and get optimized next set of
        // paths to evaluate.
        pathsToExpand = optimizePathSets(jsongCache, pathsToExpand, routerInstance.maxRefFollow);

        if (pathsToExpand.isNotEmpty) {
          pathsToExpand = collapse(pathsToExpand);
        }

        missing.addAll(matchedResults.missingPaths);
        return pathsToExpand;
      });

  }).last.then((_) => {
    'missing': missing,
    'invalidated': invalidated,
    'jsonGraph': jsongCache,
    'reportedPaths': reportedPaths
  });
}

