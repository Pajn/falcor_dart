library falcor_dart.route;

import 'package:falcor_dart/src/path_parts.dart';

typedef dynamic Handler(PathSet pathSet);

class Route {
  var route;
  final Handler get;
  final Handler set;
  final Handler call;

  int getId;
  int setId;
  int callId;

  Route(String this.route, {this.get, this.set, this.call});
}

Route route(String route, {Handler get, Handler set, Handler call}) =>
  new Route(route, get: get, set: set, call: call);
