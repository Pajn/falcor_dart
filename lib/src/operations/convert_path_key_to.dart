library falcor_dart.convert_path_key_to;

convertPathKeyTo(onRange, onKey) {
  return (keySet) {
    var isKeySet = keySet == 'object';
    var out = [];

    // The keySet we determine what type is this keyset.
    if (isKeySet) {
      if (keySet is List) {
        var reducer = null;
        keySet.forEach((key) {
          if (key == 'object') {
            reducer = onRange(out, key, reducer);
          } else {
            reducer = onKey(out, key, reducer);
          }
        });
      }

    // What passed in is a range.
      else {
        onRange(out, keySet);
      }
    }

    // simple value for keyset.
    else {
      onKey(out, keySet);
    }

    return out;
  };
}
