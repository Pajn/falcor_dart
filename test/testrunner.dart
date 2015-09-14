library falcor_dart.testruner;

import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/src/types/sentinels.dart';

class TestRunner {
  static run(value, compares) async {
    var count = 0;
    value = await value;
    // Validates against all comparables
    compares.forEach((c) {
      jsongPartialCompare(c['jsonGraph'], value['jsonGraph']);
    });

    value.forEach((k, v) {
      count++;
    });

    expect(count).toEqual(1);
  }

  static rangeToArray(ranges) {
    var out = [];
    ranges.forEach((range) {
      var to = range.to;
      for (var i = 0; i <= to; ++i) {
        out.add(i);
      }
    });

    return out;
  }

  static comparePath(List expected, actual) {
    for (int i = 0; i < expected.length; ++i) {
      var el = expected[i];
      var aEl = actual[i];
      expect(aEl).toEqual(el);
    }
  }
}

jsongPartialCompare(expectedPartial, actual) {
  traverseAndConvert(actual);
  traverseAndConvert(expectedPartial);
  contains(expectedPartial, actual, '');
}

traverseAndConvert(obj) {
  if (obj is List) {
    for (var i = 0; i < obj.length; i++) {
      if (obj[i] is Map || obj[i] is List) {
        traverseAndConvert(obj[i]);
      } else if (obj[i] is num) {
        obj[i] = obj[i] + "";
      }
    }
  } else if (obj != null && obj is Map) {
    obj.keys.forEach((k) {
      if (obj[k] is Map || obj[k] is List) {
        traverseAndConvert(obj[k]);
      } else if (obj[k] is num) {
        obj[k] = obj[k] + "";
      }
    });
  }
  return obj;
}

contains(Map expectedPartial, actual, position) {
  expectedPartial.keys.forEach((k) {
    var message = 'Object' + position;
    expect(actual.keys).toContain(k);

    if (expectedPartial[k] is! Map || actual[k] is! Map) {
      if (actual[k] is Sentinel) {
        expect(actual[k].type).toEqual(expectedPartial[k].type);
        expect(actual[k].value).toEqual(expectedPartial[k].value);
      } else {
        expect(actual[k]).toEqual(expectedPartial[k]);
      }
    } else {
      contains(expectedPartial[k], actual[k], position + '.$k');
    }
  });
}
