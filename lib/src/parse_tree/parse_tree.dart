library falcor_dart.parse_tree;

import 'package:falcor_dart/src/parse_tree/convert_types.dart';
import 'package:falcor_dart/src/keys.dart';
import 'package:falcor_dart/src/route.dart';
import 'package:falcor_dart/src/parse_tree/action_wrapper.dart';
import 'package:falcor_dart/src/utils.dart';
import 'package:falcor_dart/path_syntax.dart' as pathSyntax;

var ROUTE_ID = -3;

Map<Keys, Map> parseTree(List<Map> routes) {
  var pTree = {};
  var parseMap = {};
  routes.forEach((route) {
    // converts the virtual string path to a real path with
    // extended syntax on.
    if (route['route'] is String) {
      route['route'] = pathSyntax.parse(route['route'], true);
      convertTypes(route);
    }
    if (route['get'] != null) {
      route['getId'] = ++ROUTE_ID;
    }
    if (route['set'] != null) {
      route['setId'] = ++ROUTE_ID;
    }
    if (route['call'] != null) {
      route['callId'] = ++ROUTE_ID;
    }

    setHashOrThrowError(parseMap, route);
    route['route'] = route['route'].toList();
    buildParseTree(pTree, route);
  });
  return pTree;
}

void buildParseTree(Map<Keys, Map> node, Map routeObject, [int depth = 0]) {

  var route = routeObject['route'];
  var get = routeObject['get'];
  var set = routeObject['set'];
  var call = routeObject['call'];
  var authorize = routeObject['authorize'];
  var el = route[depth];

  if (isNumeric(el)) {
    el = parseNum(el);
  }
  var isArray = el is List;
  var i = 0;

  do {
    var value = el;
    Map<Keys, Map> next;
    if (isArray) {
      value = value[i];
    }

    // There is a ranged token in this location with / without name.
    // only happens from parsed path-syntax paths.
    if (value is Map) {
      var routeType = value['type'];
      next = decendTreeByRoutedToken(node, routeType, value);
    }

    // This is just a simple key.  Could be a ranged key.
    else {
      next = decendTreeByRoutedToken(node, value);

      // we have to create a falcor-router virtual object
      // so that the rest of the algorithm can match and coerse
      // when needed.
      if (next != null) {
        route[depth] = {'type': value, 'named': false};
      }
      else {
        node.putIfAbsent(value, () => {});
        next = node[value];
      }
    }

    // Continue to recurse or put get/set.
    if (depth + 1 == route.length) {

      // Insert match into routeSyntaxTree
      var matchObject = next[Keys.match];
      if (matchObject == null) {
        matchObject = {'authorize': authorize};
      }
      if (next[Keys.match] == null) {
        next[Keys.match] = matchObject;
      }

      if (get != null) {
        matchObject['get'] = createNamedVariables(route, get);
        matchObject['getId'] = routeObject['getId'];
      }
      if (set != null) {
        matchObject['set'] = createNamedVariables(route, set);
        matchObject['setId'] = routeObject['setId'];
      }
      if (call != null) {
        matchObject['call'] = createNamedVariables(route, call);
        matchObject['callId'] = routeObject['callId'];
      }
    } else {
      buildParseTree(next, routeObject, depth + 1);
    }

  } while (isArray && ++i < el.length);
}

/// ensure that two routes of the same precedence do not get
/// set in.
setHashOrThrowError(Map parseMap, Map routeObject) {
  var route = routeObject['route'];
  var get = routeObject['get'];
  var set = routeObject['set'];
  var call = routeObject['call'];

  getHashesFromRoute(route).map((hash) => hash.join(',')).forEach((hash) {
    if (get != null && parseMap[hash + 'get'] != null ||
        set != null && parseMap[hash + 'set'] != null ||
        call != null && parseMap[hash + 'call'] != null) {
      throw new Exception(errors.routeWithSamePrecedence + ' ' +
                      prettifyRoute(route));
    }
    if (get != null) {
      parseMap[hash + 'get'] = true;
    }
    if (set != null) {
      parseMap[hash + 'set'] = true;
    }
    if (call != null) {
      parseMap[hash + 'call'] = true;
    }
  });
}

/// decends the rst and fills in any naming information at the node.
/// if what is passed in is not a routed token identifier, then the return
/// value will be null
Map<Keys, Map> decendTreeByRoutedToken(Map<Keys, Map> node, value, [routeToken]) {
  var next = null;
  if (value is Keys) {
    switch (value) {
      case Keys.keys:
      case Keys.integers:
      case Keys.ranges:
        next = node[value];
        if (next == null) {
          next = node[value] = {};
        }
        break;
      default:
        break;
    }
  }
  if (next != null && routeToken != null) {
    // matches the naming information on the node.
    next[Keys.named] = routeToken['named'];
    next[Keys.name] = routeToken['name'];
  }

  return next;
}

/// creates a hash of the virtual path where integers and ranges
/// will collide but everything else is unique.
List<List<Map<int, String>>> getHashesFromRoute(route, [int depth = 0, List hashes, List hash]) {
  route = route.toList();
  hashes = hashes ?? [];
  hash = hash ?? [];
  var routeValue = route[depth];
  var isArray = routeValue is List;
  var length = isArray ? routeValue.length : 0;
  var idx = 0;
  var value;

  if (routeValue is Map) {
    value = routeValue['type'];
  }

  else if (!isArray) {
    value = routeValue;
  }

  do {
    if (isArray) {
      value = routeValue[idx];
    }

    if (value == Keys.integers || value == Keys.ranges) {
      if (hash.length <= depth) {
        hash.add('__I__');
      } else {
        hash[depth] = '__I__';
      }
    }

    else if (value == Keys.keys) {
      if (hash.length <= depth) {
        hash.add('__K__');
      } else {
        hash[depth] ='__K__';
      }
    }

    else {
      if (hash.length <= depth) {
        hash.add(value);
      } else {
        hash[depth] = value;
      }
    }

    // recurse down the routed token
    if (depth + 1 != route.length) {
      getHashesFromRoute(route, depth + 1, hashes, hash);
    }

    // Or just add it to hashes
    else {
      hashes.add(new List.from(hash));
    }
  } while (isArray && ++idx < length);

  return hashes;
}
