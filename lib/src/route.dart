library falcor_dart.route;

import 'package:falcor_dart/src/path_set.dart';

typedef dynamic GetHandler(PathSet pathSet);
typedef dynamic SetHandler(PathSet json);
typedef dynamic CallHandler(PathSet callPath, List args);

class Route {
  var route;
  final GetHandler get;
  final SetHandler set;
  final CallHandler call;

  int getId;
  int setId;
  int callId;

  Route(String this.route, {this.get, this.set, this.call});
}

//Route route(String route, {Handler get, Handler set, Handler call}) =>
//  new Route(route, get: get, set: set, call: call);

Map route(/*String|List*/ route, {GetHandler get, SetHandler set, CallHandler call}) {
  var routeDefinition = {'route': route};

  if (get != null) {
    routeDefinition['get'] = get;
  }
  if (set != null) {
    routeDefinition['set'] = set;
  }
  if (call != null) {
    routeDefinition['call'] = call;
  }

  return routeDefinition;
}
