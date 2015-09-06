/// To simplify this algorithm, the path must be a simple
/// path with no complex keys.
///
/// Note: The path coming in must contain no references, as
/// all set data caches have no references.
/// @param {Object} cache
/// @param {PathSet} path
getValue(Map cache, List path) {
  return path.fold(cache, (acc, key) {
    return acc[key];
  });
}
