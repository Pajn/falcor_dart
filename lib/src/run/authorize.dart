library falcor_dart.run.authorize;

import 'dart:async';
import 'package:falcor_dart/src/router.dart';
import 'package:falcor_dart/src/types/path_match.dart';

Future authorize(Router router, PathMatch match, next) async {
  if (match.authorize == null) {
    return true;
  }

  if (!await match.authorize(router, match)) {
    throw 'unauthorized';
  }

  return next;
}
