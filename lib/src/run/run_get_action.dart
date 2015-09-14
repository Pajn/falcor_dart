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
  var matchAction = await match['action'](matchAndPath['path']);
  if (matchAction is Iterable) {
    matchAction = matchAction.toList();
  }
  else {
    matchAction = [matchAction];
  }
//  var out = outputToStream(matchAction);

  return matchAction
    .map(noteToJsongOrPV(matchAndPath));
}

/// For the router there are several return types from user
/// functions.  The standard set are: synchronous type (boolean or
/// json graph) or an async type (observable or a thenable).
Stream outputToStream(valueOrObservable) {
  var value = valueOrObservable;

  if (value is Stream) {
    return value;
  } else if (value is Future) {
    return new Stream.fromFuture(value);
  } else if (value is Iterable) {
    return new Stream.fromIterable(value);
  } else {
    // this will be jsong or pathValue at this point.
    // NOTE: For the case of authorize this will be a boolean
    return new Stream.fromIterable([value]);
  }

  return value;
}

noteToJsongOrPV(match) {
  return (note) => convertNoteToJsongOrPV(match, note);
}

convertNoteToJsongOrPV(matchAndPath, note) {
  var incomingJSONGOrPathValues;

  if (true) {
    incomingJSONGOrPathValues = note;
  }

  else {
    var typeValue = $error({});
    var exception = {};

    // Rx3, what will this be called?
    if (note['exception'] != null) {
      exception = note.exception;
    }

    if (exception['throwToNext'] == true) {
      throw exception;
    }

    // If it is a special JSONGraph error then pull all the data
    if (exception is JSONGraphError) {
      typeValue = exception.typeValue;
    }

    else if (exception is Exception) {
      typeValue.value.message = exception.message;
    }

    incomingJSONGOrPathValues = {
      'path': matchAndPath['path'],
      'value': typeValue
    };
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
}
