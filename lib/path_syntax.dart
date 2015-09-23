library falcor_dart.path_syntax;

import 'package:falcor_dart/src/path_syntax/parse_tree/head.dart';
import 'package:falcor_dart/src/path_syntax/tokenizer.dart';

List parse(string, [extendedRules]) {
  return head(new Tokenizer(string, extendedRules));
}

/// Constructs the paths from paths / pathValues that have strings.
/// If it does not have a string, just moves the value into the return
/// results.
List parsePathsOrPathValues(List paths, [ext]) {
  if (paths == null) {
    return [];
  }

  var out = [];
  for (var path in paths) {
    // Is the path a string
    if (path is String) {
      out.add(parse(path, ext));
    }

    // is the path a path value with a string value.
    else if (path is Map && path['path'] is String) {
      out.add({'path': parse(path['path'], ext), 'value': path['value']});
    }

    // just copy it over.
    else {
      out.add(path);
    }
  }

  return out;
}

/// If the argument is a string, this with convert, else just return
/// the path provided.
List parsePath(path, [ext]) {
  if (path == null) {
    return [];
  }

  if (path is String) {
    return parse(path, ext);
  }

  return path;
}
