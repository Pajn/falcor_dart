library falcor_dart.path_parts;

class Key {

}

class PathSet {
  final List pathParts = [];
  final Map namedPathParts = {};

  get last => pathParts.last;
  int get length => pathParts.length;

  PathSet();

  add(value) => pathParts.add(value);

  operator [](key) {
    if (key is int) return pathParts[key];
    else if (key is String) return namedPathParts[key];
    else {
      throw new UnsupportedError('Unsupported type "${key.runtimeType}" as PathSet key');
    }
  }

  operator []=(key, value) {
    namedPathParts[key] = value;
  }
}
