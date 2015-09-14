library falcor_dart.exceptions.dart;

class CallJsonGraphWithoutPaths extends Error {
  String toString() => 'Any JSONG-Graph returned from call must have paths.';
}

class FalcorError extends Error {
  final throwToNext = false;
}

class CircularReferenceError extends FalcorError {
  String toString() => 'There appears to be a circular reference, maximum reference following exceeded.';
}

class InnerReferenceError extends FalcorError {
  final throwToNext = true;
  String toString() => 'References with inner references are not allowed.';
}
