library falcor_dart.parse_tree.convert_path_to_route;

import 'package:falcor_dart/src/keys.dart';
import 'package:falcor_dart/src/operations/convert_path_key_to_integers.dart';
import 'package:falcor_dart/src/operations/convert_path_key_to_range.dart';

/// takes the path that was matched and converts it to the
/// virtual path.
convertPathToRoute(path, route) {
  var matched = [];
  // Always use virtual path since path can be longer since
  // it contains suffixes.
  for (var i = 0, len = route.length; i < len; ++i) {

    if (route[i] is Map && route[i]['type'] is Keys) {
      var virt = route[i];
      switch (virt['type']) {
        case Keys.ranges:
          matched.add(convertPathKeyToRange(path[i]));
          break;
        case Keys.integers:
          matched.add(convertPathKeyToIntegers(path[i]));
          break;
        case Keys.keys:
          matched[i] =
          convertPathKeyToKeys(path[i]);
          break;
        default:
          var err = new Exception('Unknown route type.');
//          err.throwToNext = true;
          break;
      }
      if (virt['named']) {
        matched[virt['name']] = matched.last;
      }
    }

    // Dealing with specific keys or array of specific keys.
    // If route has an array at this position, arrayify the
    // path[i] element.
    else {
      if (route[i] is List && path[i] is! List) {
        matched.add([path[i]]);
      }

      else {
        matched.add(path[i]);
      }
    }
  }

  return matched;
}
