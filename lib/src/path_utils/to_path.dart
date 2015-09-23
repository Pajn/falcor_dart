library falcor_dart.to_path;

import 'package:falcor_dart/src/types/range.dart';
import 'package:falcor_dart/src/utils.dart';

/// [lengths] [List] or [Map]<int, dynamic>
List toPaths(lengths) {
  var allPaths = [];

  if (lengths is List) {
    lengths = lengths.asMap();
  }

  lengths.forEach((length, pathmap) {
    if (pathmap is Map) {
      var paths = collapsePathMap(pathmap, 0, length)['sets'];
      for (var path in paths) {
        allPaths.add(collapsePathSetIndexes(path));
      }
    }
  });

  return allPaths;
}

isObject(value) {
  return value is Map;
}

Map collapsePathMap(Map pathmap, int depth, int length) {
  var key;
  var code = getHashCode(depth);
  var subs = {};

  var codes = [];
  var codesIndex = -1;
  var codesCount = 0;

  var pathsets = [];
  var pathsetCount = 0;

  var subPath,
      subCode,
      subKeys,
      subKeysIndex,
      subKeysCount,
      subSets,
      pathsetIndex,
      firstSubKey,
      pathsetClone;

  subKeysIndex = -1;

  if (depth < length - 1) {
    subKeys = getSortedKeys(pathmap);

    while (++subKeysIndex < subKeys.length) {
      key = subKeys[subKeysIndex];
      subPath = collapsePathMap(pathmap[key], depth + 1, length);
      subCode = subPath['code'];
      if (subs[subCode] != null) {
        subPath = subs[subCode];
      } else {
        codesCount++;
        codes.add(subCode);
        subPath = subs[subCode] = {'keys': [], 'sets': subPath['sets']};
      }
      code = getHashCode(code + key.toString() + subCode);

      if (isNumeric(key)) {
        subPath['keys'].add(parseNum(key));
      } else {
        subPath['keys'].add(key);
      }
    }

    while (++codesIndex < codesCount) {
      key = codes[codesIndex];
      subPath = subs[key];
      subKeys = subPath['keys'];
      subKeysCount = subKeys.length;

      if (subKeysCount > 0) {
        subSets = subPath['sets'];
        firstSubKey = subKeys.first;

        for (var pathset in subSets) {
          pathsetIndex = -1;
          pathsetCount = pathset.length;
          pathsetClone = new List(pathsetCount + 1);
          pathsetClone[0] = (subKeysCount > 1 ? subKeys : null) ?? firstSubKey;

          while (++pathsetIndex < pathsetCount) {
            pathsetClone[pathsetIndex + 1] = pathset[pathsetIndex];
          }

          pathsetCount++;
          pathsets.add(pathsetClone);
        }
      }
    }
  } else {
    subKeys = getSortedKeys(pathmap);
    pathsetCount++;
    if (subKeys.length > 1) {
      pathsets.add([subKeys]);
    } else {
      pathsets.add(subKeys);
    }
    while (++subKeysIndex < subKeys.length) {
      code = getHashCode(code + subKeys[subKeysIndex].toString());
    }
  }

  return {'code': code, 'sets': pathsets};
}

List collapsePathSetIndexes(List pathset) {
  return pathset.map((keyset) {
    if (keyset is List) {
      return collapseIndex(keyset);
    }

    return keyset;
  }).toList();
}

/**
 * Collapse range indexers, e.g. when there is a continuous
 * range in an array, turn it into an object instead:
 *
 * [1,2,3,4,5,6] => {"from":1, "to":6}
 *
 * @private
 */
collapseIndex(List keyset) {
  // Do we need to dedupe an indexer keyset if they're duplicate consecutive integers?
  // var hash = {};
  var keyIndex = -1;
  var keyCount = keyset.length - 1;
  var isSparseRange = keyCount > 0;

  while (++keyIndex <= keyCount) {
    var key = keyset[keyIndex];

    if (!isNumber(key) /* || hash[key] === true*/) {
      isSparseRange = false;
      break;
    }
    // hash[key] = true;
    // Cast number indexes to integers.
    keyset[keyIndex] = key is int ? key : int.parse(key);
  }

  if (isSparseRange) {
    keyset.sort(sortListAscending);

    var from = keyset[0];
    var to = keyset[keyCount];

    // If we re-introduce deduped integer indexers, change this comparson to "===".
    if (to - from <= keyCount) {
      return new Range(from, to);
    }
  }

  return keyset;
}

sortListAscending(a, b) {
  return a - b;
}

List getSortedKeys(Map map, [sort(a, b)]) {
  var keys = new List.from(map.keys);
  if (sort == null) {
    keys.sort((a, b) => a.toString().compareTo(b.toString()));
  } else {
    keys.sort(sort);
  }
  return keys;
}

String getHashCode(Object key) {
  var keyAsString = key.toString();
  var code = 5381;
  var index = -1;
  var count = keyAsString.length;
  while (++index < count) {
    code = (code << 5) + code + keyAsString.codeUnitAt(index);
  }
  return code.toString();
}

/**
 * Return true if argument is a number or can be cast to a number
 * @private
 */
bool isNumber(val) {
  // parseFloat NaNs numeric-cast false positives (null|true|false|"")
  // ...but misinterprets leading-number strings, particularly hex literals ("0x...")
  // subtraction forces infinities to NaN
  // adding 1 corrects loss of precision from parseFloat (#15100)
  return parseNum(val) >= 0;
}
