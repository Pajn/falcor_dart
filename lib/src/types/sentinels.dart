library falcor_dart.sentinels;

import 'package:falcor_dart/path_syntax.dart' as pathSyntax;

class Sentinel {
  final String type;
  final value;
  final int expires;
  final int timestamp;
  final int size;

  bool get isAtom => type == 'atom';
  bool get isError => type == 'error';
  bool get isRef => type == 'ref';

  const Sentinel(this.type, this.value,
      {this.expires, this.timestamp, this.size});

  factory Sentinel.fromJson(Map json) {
    switch (json[r'$type']) {
      case 'ref':
      case 'atom':
      case 'error':
        return new Sentinel(json[r'$type'], json[r'value'],
            expires: json[r'$expires'],
            timestamp: json[r'$timestamp'],
            size: json[r'$size']);
      default:
        throw new UnsupportedError(
            'Unsupported sentinel type ${json[r'$type']}');
    }
  }

  Map toJson() {
    var json = {r'$type': type, 'value': value};

    if (expires != null) json[r'$expires'] = expires;
    if (timestamp != null) json[r'$timestamp'] = timestamp;
    if (size != null) json[r'$size'] = size;

    return json;
  }

  String toString() => 'Sentinel({type: $type, value: $value})';

  operator ==(other) {
    return other is Sentinel && toString() == other.toString();
  }
}

Sentinel $ref(path, {int expires, int timestamp, int size}) =>
    new Sentinel(r'ref', path is String ? pathSyntax.parse(path) : path,
        expires: expires, timestamp: timestamp, size: size);

Sentinel $atom(value, {int expires, int timestamp, int size}) =>
    new Sentinel(r'atom', value,
        expires: expires, timestamp: timestamp, size: size);

Sentinel $error(value, {int expires, int timestamp, int size}) =>
    new Sentinel(r'error', value,
        expires: expires, timestamp: timestamp, size: size);
