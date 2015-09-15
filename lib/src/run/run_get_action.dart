library falcor_dart.run_get_action;
import 'dart:async';

import 'package:falcor_dart/src/types/sentinels.dart';
import 'package:falcor_dart/src/router.dart';
import 'package:falcor_dart/src/utils.dart';

typedef Stream ActionRunner(Map matchAndPath);

ActionRunner runGetAction(Router routerInstance, Map jsongCache) {
  return (Map matchAndPath) {
    return getAction(routerInstance, matchAndPath, jsongCache);
  };
}

Future<List> getAction(Router routerInstance, Map matchAndPath, Map jsongCache) async {
  var match = matchAndPath['match'];
  try {
    var matchAction = await match['action'](matchAndPath['path']);
    if (matchAction is Iterable) {
      matchAction = matchAction.toList();
    }

    return [matchAction]
        .map(noteToJsongOrPV(matchAndPath));
  } catch(error) {
    rethrow;
    return [convertNoteToJsongOrPV(matchAndPath, error, error: true)];
  }
}

noteToJsongOrPV(match) {
  return (note) => convertNoteToJsongOrPV(match, note);
}

convertNoteToJsongOrPV(matchAndPath, note, {bool error: false}) {
  var incomingJSONGOrPathValues;

  if (error) {
    var typeValue = $error({});
    var exception = note;

//    if (exception['throwToNext'] == true) {
//      throw exception;
//    }

    // If it is a special JSONGraph error then pull all the data
    if (exception is JSONGraphError) {
      typeValue = exception.typeValue;
    }

    else if (exception is Exception) {
      typeValue.value['message'] = exception.message;
    }

    incomingJSONGOrPathValues = {
      'path': matchAndPath['path'],
      'value': typeValue
    };
  }

  else {
    incomingJSONGOrPathValues = note;
  }

  // If its jsong we may need to optionally attach the
  // paths if the paths do not exist
  if (isJSONG(incomingJSONGOrPathValues) &&
      incomingJSONGOrPathValues['paths'] == null) {

    incomingJSONGOrPathValues = {
      'jsonGraph': incomingJSONGOrPathValues['jsonGraph'],
      'paths': [matchAndPath['path']]
    };
  }

  return [matchAndPath['match'], incomingJSONGOrPathValues];
}

class JSONGraphError {
  var typeValue;
}
