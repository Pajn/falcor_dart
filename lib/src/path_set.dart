library falcor_dart.path_set;

import 'dart:collection';

class PathSet extends Object with ListMixin implements List {
  final List pathParts;
  final Map namedPathParts;

  int get length => pathParts.length;
  set length(int length) => pathParts.length = length;

  PathSet()
      : pathParts = [],
        namedPathParts = {};
  PathSet.from(PathSet pathSet)
      : pathParts = pathSet.pathParts,
        namedPathParts = pathSet.namedPathParts;

  void add(element) => pathParts.add(element);
  void addAll(Iterable iterable) => pathParts.addAll(iterable);

  operator [](key) {
    if (key is int) return pathParts[key];
    else if (key is String) return namedPathParts[key];
    else {
      throw new UnsupportedError(
          'Unsupported type "${key.runtimeType}" as PathSet key');
    }
  }

  operator []=(key, value) {
    if (key is int) {
      if (key < pathParts.length) {
        return pathParts[key] = value;
      } else if (key == pathParts.length) {
        return pathParts.add(value);
      } else {
        throw new StateError('Cant set index after end');
      }
    } else if (key is String) return namedPathParts[key] = value;
    else {
      throw new UnsupportedError(
          'Unsupported type "${key.runtimeType}" as PathSet key');
    }
  }
}
