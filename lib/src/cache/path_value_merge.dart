library falcor_dart.path_value_merge;

import 'package:falcor_dart/src/path_utils/iterate_key_set.dart';


/**
 * merges pathValue into a cache
 */
Map pathValueMerge(Map cache, Map pathValue) {
  var refs = [];
  var values = [];
  var invalidations = [];

  // The invalidation case.  Needed for reporting
  // of call.
  if (pathValue['value'] == null) {
    invalidations.add({'path': pathValue['path']});
  }

  // References.  Needed for evaluationg suffixes in
  // both call and get/set.
  else if (pathValue['value'][r'$type'] == r'$ref') {
    refs.add({
      'path': pathValue['path'],
      'value': pathValue['value']['value']
    });
  }


  // Values.  Needed for reporting for call.
  else {
    values.add(pathValue);
  }

  if (invalidations.isEmpty) {
    // Merges the values/refs/invs into the cache.
    innerPathValueMerge(cache, pathValue);
  }

  return {
    'references': refs,
    'values': values,
    'invalidations': invalidations
  };
}

innerPathValueMerge(Map cache, pathValue) {
  var path = pathValue.path;
  var curr = cache;
  var next, key, cloned, outerKey, iteratorNote;
  var i = 0;

  for (var len = path.length - 1; i < len; ++i) {
    outerKey = path[i];

    // Setup the memo and the key.
    if (outerKey is Map) {
      iteratorNote = {};
      key = iterateKeySet(outerKey, iteratorNote);
    } else {
      key = outerKey;
      iteratorNote = false;
    }

    do {
      next = curr[key];

      if (!next) {
        next = curr[key] = {};
      }

      if (iteratorNote) {
        innerPathValueMerge(
            next, {
          'path': path.slice(i + 1),
          'value': pathValue.value
        });

        if (!iteratorNote.done) {
          key = iterateKeySet(outerKey, iteratorNote);
        }
      }

      else {
        curr = next;
      }
    } while (iteratorNote && !iteratorNote.done);

    // All memoized paths need to be stopped to avoid
    // extra key insertions.
    if (iteratorNote) {
      return;
    }
  }


  // TODO: This clearly needs a re-write.  I am just unsure of how i want
  // this to look.  Plus i want to measure performance.
  outerKey = path[i];

  iteratorNote = {};
  key = iterateKeySet(outerKey, iteratorNote);

  do {

    cloned = clone(pathValue['value']);
    curr[key] = cloned;

    if (!iteratorNote['done']) {
      key = iterateKeySet(outerKey, iteratorNote);
    }
  } while (!iteratorNote['done']);
}

clone(a) {
  print(a.runtimeType);

  if (a is Map) {
    return new Map.from(a);
  } else if (a is List) {
    return new List.from(a);
  }

  return a;
}
