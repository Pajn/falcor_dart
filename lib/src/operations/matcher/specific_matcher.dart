library falcor_dart.specific_matcher;

import 'package:falcor_dart/src/path_utils/iterate_key_set.dart';

List specificMatcher(keySet, currentNode) {
  // --------------------------------------
  // Specific key
  // --------------------------------------
  var iteratorNote = {};
  var nexts = [];

  var key = iterateKeySet(keySet, iteratorNote);
  do {
    if (currentNode[key] != null) {
      nexts.add(key);
    }

    if (!iteratorNote['done']) {
      key = iterateKeySet(keySet, iteratorNote);
    }
  } while (!iteratorNote['done']);

  return nexts;
}
