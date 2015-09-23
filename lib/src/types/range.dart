library falcor_dart.types.range;

class Range {
  int from;
  int to;

  int get length => to - from;

  Range(this.from, this.to) {
    from ??= 0;
    to ??= from;
  }

  List toList() => new List.generate(length + 1, (index) => index + from);

  Map toJson() => {'from': from, 'to': to,};

  String toString() => 'Range{from: $from, to: $to}';

  operator ==(other) {
    return other is Range && other.from == from && other.to == to;
  }
}
