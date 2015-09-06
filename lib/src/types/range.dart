library falcor_dart.types.range;

class Range {
  int from;
  int to;

  int get length => to - from;

  List toList() => new List.generate(length, (index) => index + from);
}
