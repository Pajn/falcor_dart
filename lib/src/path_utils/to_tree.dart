library falcor_dart.to_tree;

import 'package:falcor_dart/src/path_utils/iterate_key_set.dart';

Map toTree(List paths) {
  return paths.fold({}, (acc, path) {
    innerToTree(acc, path, 0);
    return acc;
  });
}

innerToTree(seed, List path, int depth) {
  var keySet = path[depth];
  var iteratorNote = {};
  var key;
  var nextDepth = depth + 1;

  key = iterateKeySet(keySet, iteratorNote);

  do {
    var next = seed[key];
    if (next == null) {
      if (nextDepth == path.length) {
        seed[key] = null;
      } else {
        next = seed[key] = {};
      }
    }

    if (nextDepth < path.length) {
      innerToTree(next, path, nextDepth);
    }

    if (!iteratorNote['done']) {
      key = iterateKeySet(keySet, iteratorNote);
    }
  } while (!iteratorNote['done']);
}
