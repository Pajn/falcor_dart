library falcor_dart.parse_tree.convert_path_to_route;

import 'package:falcor_dart/src/keys.dart';

/// takes the path that was matched and converts it to the
/// virtual path.
convertPathToRoute(path, route) {
  var matched = [];
  // Always use virtual path since path can be longer since
  // it contains suffixes.
  for (var i = 0, len = route.length; i < len; ++i) {

    if (route[i].type) {
      var virt = route[i];
      switch (virt.type) {
        case Keys.ranges:
          matched[i] =
          convertPathKeyToRange(path[i]);
          break;
        case Keys.integers:
          matched[i] =
          convertPathKeyToIntegers(path[i]);
          break;
        case Keys.keys:
          matched[i] =
          convertPathKeyToKeys(path[i]);
          break;
        default:
          var err = new Error('Unknown route type.');
          err.throwToNext = true;
          break;
      }
      if (virt.named) {
        matched[virt.name] = matched[matched.length - 1];
      }
    }

    // Dealing with specific keys or array of specific keys.
    // If route has an array at this position, arrayify the
    // path[i] element.
    else {
      if (route[i] is List && path[i] is! List) {
        matched[matched.length] = [path[i]];
      }

      else {
        matched[matched.length] = path[i];
      }
    }
  }

  return matched;
}
