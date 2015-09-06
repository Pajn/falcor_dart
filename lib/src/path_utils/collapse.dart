library falcor_dart.path_utils.collapse;

import 'package:falcor_dart/src/path_utils/to_tree.dart';
import 'package:falcor_dart/src/path_utils/to_path.dart';

collapse(List paths) {
  Map collapseMap = paths.fold({}, (acc, path) {
    var len = path.length;
    if (acc.containsKey(len)) {
      acc[len] = [];
    }
    acc[len].add(path);
    return acc;
  });

  collapseMap.forEach((key, value) {
    collapseMap[key] = toTree(value);
  });

  return toPaths(collapseMap);
}
