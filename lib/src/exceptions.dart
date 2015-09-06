library falcor_dart.exceptions.dart;

class CallJsonGraphWithoutPaths extends Exception {
  factory CallJsonGraphWithoutPaths() => new Exception('Any JSONG-Graph returned from call must have paths.');
}
