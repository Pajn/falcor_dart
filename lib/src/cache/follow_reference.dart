library falcor_dart.cache.follow_reference;

/// performs the simplified cache reference follow. This
/// differs from get as there is just following and reporting,
/// not much else.
followReference(Map cacheRoot, List ref, int maxRefFollow) {
  var current = cacheRoot;
  var refPath = ref;
  var depth = -1;
  var length = refPath.length;
  var key, next, type;
  var referenceCount = 0;

  while (++depth < length) {
    key = refPath[depth];
    next = current[key];
    type = next && next.$type;

    if (next == null || type != null && type != r'$ref') {
      current = next;
      break;
    }

    // Show stopper exception.  This route is malformed.
    if (type == r'$ref' && depth + 1 < length) {
      var err = new Exception(errors.innerReferences);
//      err.throwToNext = true;
      throw err;
    }

    // potentially follow reference
    if (depth + 1 == length) {
      if (type == r'$ref') {
        depth = -1;
        refPath = next.value;
        length = refPath.length;
        next = cacheRoot;
        referenceCount++;
      }

      if (referenceCount > maxRefFollow) {
        throw new Exception(errors.circularReference);
      }
    }
    current = next;
  }

  return [current, new List.from(refPath)];
}
