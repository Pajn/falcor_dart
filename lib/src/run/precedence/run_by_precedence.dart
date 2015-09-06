library falcor_dart.run.precendence.run_by_precedence;

import 'dart:async';
import 'package:falcor_dart/src/run/precedence/get_executable_matches.dart';

/// Sorts and strips the set of available matches given the pathSet.
Stream<Map> runByPrecedence(pathSet, matches, actionRunner) {

  // Precendence matching
  var sortedMatches = matches.sort((a, b) {
    if (a.precedence > b.precedence) {
      return 1;
    } else if (a.precedence < b.precedence) {
      return -1;
    }

    return 0;
  });

  var matchesWithPaths = getExecutableMatches(sortedMatches, [pathSet]);
  return new Stream.fromIterable(matchesWithPaths)
    .asyncExpand(actionRunner)

    // Note: We do not wait for each observable to finish,
    // but repeat the cycle per onNext.
    .map((actionTuple) {

      return {
        'match': actionTuple[0],
        'value': actionTuple[1]
      };
    });
}
