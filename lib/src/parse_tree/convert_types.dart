library falcor_dart.parse_tree.convert_types;

import 'package:falcor_dart/src/keys.dart';

void convertTypes(virtualPath) {
  virtualPath['route'] = virtualPath['route'].map((key) {
    if (key is Map) {
      if (key['type'] is String) {
        switch (key['type']) {
          case 'keys':
            key['type'] = Keys.keys;
            break;
          case 'integers':
            key['type'] = Keys.integers;
            break;
          case 'ranges':
            key['type'] = Keys.ranges;
            break;
          default:
            var err = new Exception('Unknown route type.');
            //          err.throwToNext = true;
            break;
        }
      }
    }
    return key;
  });
}
