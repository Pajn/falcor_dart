library falcor_dart.exceptions.dart;

class FalcorError extends Error {
  final throwToNext = false;
}

class CallJsonGraphWithoutPaths extends FalcorError {
  final throwToNext = true;
  String toString() => 'Any JSONG-Graph returned from call must have paths.';
}

class CircularReferenceError extends FalcorError {
  String toString() =>
      'There appears to be a circular reference, maximum reference following exceeded.';
}

class InnerReferenceError extends FalcorError {
  final throwToNext = true;
  String toString() => 'References with inner references are not allowed.';
}

class NullReturnedError extends FalcorError {
  final throwToNext = true;
  String toString() => 'Returning null from an handler is not allowed.';
}
