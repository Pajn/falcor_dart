library falcor_dart.exceptions.dart;

class CallJsonGraphWithoutPaths extends Error {
  facCallJsonGraphWithoutPaths() : super('Any JSONG-Graph returned from call must have paths.');
}
