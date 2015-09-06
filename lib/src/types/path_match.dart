library falcor_dart.types.path_match;

import 'dart:async';
import 'package:falcor_dart/src/router.dart';

typedef Future<bool> AuthorizeHandler(Router router, PathMatch match);

/// Named Match in Falcor Js but nameclashes with [Match] in [dart:core]
class PathMatch {
  List path;
  List virtual;
  int precedence;
  AuthorizeHandler authorize;
}
