library falcor_dart.path_syntax;

import 'package:falcor_dart/src/path_syntax/parse_tree/head.dart';
import 'package:falcor_dart/src/path_syntax/tokenizer.dart';

List parse(string, [extendedRules]) {
  return head(new Tokenizer(string, extendedRules));
}

// Constructs the paths from paths / pathValues that have strings.
// If it does not have a string, just moves the value into the return
// results.
List parsePathsOrPathValues(paths, [ext]) {
  if (!paths) {
    return [];
  }

  var out = [];
  for (var i = 0, len = paths.length; i < len; i++) {

    // Is the path a string
    if (paths[i] is String) {
      out[i] = parse(paths[i], ext);
    }

    // is the path a path value with a string value.
    else if (paths[i].path is String) {
      out[i] = {
        'path': parse(paths[i].path, ext), 'value': paths[i].value
      };
    }

    // just copy it over.
    else {
      out[i] = paths[i];
    }
  }

  return out;
}

// If the argument is a string, this with convert, else just return
// the path provided.
List parsePath(path, [ext]) {
  if (!path) {
    return [];
  }

  if (path is String) {
    return parse(path, ext);
  }

  return path;
}
