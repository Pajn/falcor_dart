library falcor_dart.run.precendence.run_by_precedence;

import 'dart:async';
import 'package:falcor_dart/src/run/precedence/get_executable_matches.dart';
import 'package:falcor_dart/src/run/run_get_action.dart';

/// Sorts and strips the set of available matches given the pathSet.
Future<List<Map>> runByPrecedence(
    pathSet, List matches, ActionRunner actionRunner) async {
  // Precendence matching
  var sortedMatches = new List.from(matches)
    ..sort((a, b) {
      if (a['precedence'] > b['precedence']) {
        return 1;
      } else if (a['precedence'] < b['precedence']) {
        return -1;
      }

      return 0;
    });

  var matchesWithPaths = getExecutableMatches(sortedMatches, [pathSet]);
  var actionTuples = await Future.wait(matchesWithPaths.map(actionRunner));
  return actionTuples
      .expand((actionTuples) => actionTuples)

      // Note: We do not wait for each observable to finish,
      // but repeat the cycle per onNext.
      .map((actionTuple) {
    return {'match': actionTuple[0], 'value': actionTuple[1]};
  }).toList();
}
