library falcor_dart.cache.follow_reference;

import 'package:falcor_dart/src/types/sentinels.dart';
import 'package:falcor_dart/src/exceptions.dart';

/// performs the simplified cache reference follow. This
/// differs from get as there is just following and reporting,
/// not much else.
List followReference(Map cacheRoot, List ref, int maxRefFollow) {
  var current = cacheRoot;
  var refPath = ref;
  var depth = -1;
  var length = refPath.length;
  var key, next;
  var referenceCount = 0;

  while (++depth < length) {
    key = refPath[depth];
    next = current[key];

    if (next == null || next is Sentinel && !next.isRef) {
      current = next;
      break;
    }

    // Show stopper exception.  This route is malformed.
    if (next is Sentinel && next.isRef && depth + 1 < length) {
      throw new InnerReferenceError();
    }

    // potentially follow reference
    if (depth + 1 == length) {
      if (next is Sentinel && next.isRef) {
        depth = -1;
        refPath = next.value;
        length = refPath.length;
        next = cacheRoot;
        referenceCount++;
      }

      if (referenceCount > maxRefFollow) {
        throw new CircularReferenceError();
      }
    }
    current = next;
  }
  print(current);

  return [current, new List.from(refPath)];
}
