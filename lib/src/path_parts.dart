library falcor_dart.path_parts;

class Key {

}

class PathSet {
  final List pathParts;
  final Map namedPathParts;

  PathSet(this.pathParts, this.namedPathParts);

  operator [](key) {
    if (key is int) return pathParts[key];
    else if (key is String) return namedPathParts[key];
    else {
      throw new UnsupportedError('Unsupported type "${key.runtimeType}" as PathSet key');
    }
  }
}
