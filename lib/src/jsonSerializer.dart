library falcor_dart.json_serializer;

import 'package:falcor_dart/src/types/range.dart';
import 'package:falcor_dart/src/types/sentinels.dart';

serializeToJson(object) {
  if (object is String || object is num || object is bool || object == null) {
    return object;
  } else if (object is Map) {
    var map = {};
    object.forEach((key, value) {
      map[key.toString()] = serializeToJson(value);
    });
    return map;
  } else if (object is List) {
    return object.map(serializeToJson).toList();
  } else if (object is Range) {
    return object.toJson();
  } else if (object is Sentinel) {
    var value = serializeToJson(object.value);
    object = object.toJson();
    object['value'] = value;
    return object;
  } else {
    try {
      return object.toJson();
    } on NoSuchMethodError {}
    throw "Can't convert ${object.runtimeType} to json";
  }
}
