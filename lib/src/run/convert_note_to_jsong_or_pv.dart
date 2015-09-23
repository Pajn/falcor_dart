library falcor_dart.run.convert_note_to_jsong_or_pv;
import 'package:falcor_dart/src/types/sentinels.dart';
import 'package:falcor_dart/src/exceptions.dart';
import 'package:falcor_dart/src/utils.dart';

noteToJsongOrPV(match) {
  return (note) => convertNoteToJsongOrPV(match, note);
}

convertNoteToJsongOrPV(matchAndPath, note, {bool error: false}) {
  var incomingJSONGOrPathValues;

  if (error) {
    var typeValue = $error({});
    var exception = note;

    if (exception is FalcorError && exception.throwToNext) {
      throw exception;
    }

    // If it is a special JSONGraph error then pull all the data
    if (exception is Exception) {
      typeValue.value['message'] = exception.message;
    }

    else {
      typeValue.value['message'] = exception.toString();
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
