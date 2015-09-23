library falcor_dart.run_get_action;

import 'dart:async';

import 'package:falcor_dart/src/router.dart';
import 'package:falcor_dart/src/run/convert_note_to_jsong_or_pv.dart';

typedef Stream ActionRunner(Map matchAndPath);

ActionRunner runGetAction(Router routerInstance, Map jsongCache) {
  return (Map matchAndPath) {
    return getAction(routerInstance, matchAndPath, jsongCache);
  };
}

Future<List> getAction(
    Router routerInstance, Map matchAndPath, Map jsongCache) async {
  var match = matchAndPath['match'];
  try {
    var matchAction = await match['action'](matchAndPath['path']);
    if (matchAction is Iterable) {
      matchAction = matchAction.toList();
    }

    return [matchAction].map(noteToJsongOrPV(matchAndPath));
  } catch (error) {
    return [convertNoteToJsongOrPV(matchAndPath, error, error: true)];
  }
}
