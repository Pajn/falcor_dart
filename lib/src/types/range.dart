library falcor_dart.types.range;

class Range {
  int from;
  int to;

  int get length => to - from;

  Range(this.from, this.to);

  List toList() => new List.generate(length, (index) => index + from);

  String toString() => 'Range{from: $from, to: $to}';

  operator ==(other) {
    return other is Range && other.from == from && other.to == to;
  }
}
