library falcor_dart.run_get_action;
import 'dart:async';

import 'package:falcor_dart/src/types/sentinels.dart';
import 'package:falcor_dart/src/router.dart';
import 'package:falcor_dart/src/utils.dart';

runGetAction(Router routerInstance, Map jsongCache) {
  return (matchAndPath) {
    return getAction(routerInstance, matchAndPath, jsongCache);
  };
}

Stream getAction(Router routerInstance, matchAndPath, Map jsongCache) {
  var match = matchAndPath.match;
  var matchAction = match.action(matchAndPath.path);
  var out = outputToStream(matchAction);

  return out
    .where((note) => note.kind != 'C')
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
  var kind = note.kind;
  var onNext = 'N';

  if (kind == onNext) {
    incomingJSONGOrPathValues = note.value;
  }

  else {
    var typeValue = $error({});
    var exception = {};

    // Rx3, what will this be called?
    if (note.exception) {
      exception = note.exception;
    }

    if (exception.throwToNext) {
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
      'path': matchAndPath.path,
      'value': typeValue
    };
  }

  // If its jsong we may need to optionally attach the
  // paths if the paths do not exist
  if (isJSONG(incomingJSONGOrPathValues) &&
      !incomingJSONGOrPathValues.paths) {

    incomingJSONGOrPathValues = {
      'jsonGraph': incomingJSONGOrPathValues.jsonGraph,
      'paths': [matchAndPath.path]
    };
  }

  return [matchAndPath.match, incomingJSONGOrPathValues];
}

class JSONGraphError {
}
