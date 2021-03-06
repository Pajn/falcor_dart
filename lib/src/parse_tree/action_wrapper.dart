library falcor_dart.parse_tree.action_wrapper;

import 'package:falcor_dart/src/route.dart';
import 'package:falcor_dart/src/parse_tree/convert_path_to_route.dart';
import 'package:falcor_dart/src/utils.dart';

createNamedVariables(List route, action) {
  return (matchedPath) {
    var convertedArguments;
    var len = -1;
    var isJSONObject = matchedPath is! List;

    // A set uses a json object
    if (isJSONObject) {
      convertedArguments = matchedPath;
    }

    // Could be an array of pathValues for a set operation.
    else if (isPathValue(matchedPath[0])) {
      convertedArguments = [];

      matchedPath.forEach((pV) {
        pV.path = convertPathToRoute(pV.path, route);
        convertedArguments[++len] = pV;
      });
    }

    // else just convert and assign
    else {
      convertedArguments = convertPathToRoute(matchedPath, route);
    }
    return action(convertedArguments);
  };
}

createNamedVariablesCall(List route, action) {
  return (matchedPath, args) {
    var convertedArguments;
    var len = -1;
    var isJSONObject = matchedPath is! List;

    // A set uses a json object
    if (isJSONObject) {
      convertedArguments = matchedPath;
    }

    // Could be an array of pathValues for a set operation.
    else if (isPathValue(matchedPath[0])) {
      convertedArguments = [];

      matchedPath.forEach((pV) {
        pV.path = convertPathToRoute(pV.path, route);
        convertedArguments[++len] = pV;
      });
    }

    // else just convert and assign
    else {
      convertedArguments = convertPathToRoute(matchedPath, route);
    }
    return action(convertedArguments, args);
  };
}
