library falcor_dart.matcher.dart;

import 'package:falcor_dart/src/precedence.dart';
import 'package:falcor_dart/src/keys.dart';
import 'package:falcor_dart/src/utils.dart';
import 'package:falcor_dart/src/path_utils/collapse.dart';
import 'package:falcor_dart/src/operations/matcher/specific_matcher.dart';
import 'package:falcor_dart/src/operations/matcher/pluck_integers.dart';

var intTypes = [{
  'type': Keys.ranges,
  'precedence': Precedence.ranges
}, {
  'type': Keys.integers,
  'precedence': Precedence.integers
}];
var keyTypes = [{
  'type': Keys.keys,
  'precedence': Precedence.keys
}];
var allTypes = new List.from(intTypes)..addAll(keyTypes);

/// @return {matched: Array.<Match>, missingPaths: Array.<Array>}
class PathMatch {
  List matched;
  List<List> missingPaths;
}

typedef PathMatch Matcher(String method, List paths);

/// Creates a custom matching function for the match tree.
/// [rst] The routed syntax tree
/// String [method] the method to call at the end of the path.
Matcher matcher(Map<Keys, Map> rst) {

  /// This is where the matching is done.  Will recursively
  /// match the paths until it has found all the matchable
  /// functions.
  return (String method, List paths) {
    var matched = [];
    var missing = [];
    match(rst, paths, method, matched, missing);

    // We are at the end of the path but there is no match and its a
    // call. Therefore we are going to throw an informative error.
    if (method == 'call' && matched.isEmpty) {
      var err = new Exception('function does not exist');
//      err.throwToNext = true;

      throw err;
    }

    Map reducedMatched = matched.fold({}, (Map<int, List> acc, Map matchedRoute) {
      if (!acc.containsKey(matchedRoute['id'])) {
        acc[matchedRoute['id']] = [];
      }
      acc[matchedRoute['id']].add(matchedRoute);

      return acc;
    });

    var collapsedMatched = [];

    reducedMatched.values.forEach((reducedMatch) {

      // This one has no issues with collapsing, its ok to
      // merge it back into the collapsedMatched array
      if (reducedMatch.length == 1) {
        return collapsedMatched.add(reducedMatch[0]);
      }

      // Since there are more than 1 routes, we need to see if
      // they can collapse and alter the amount of arrays.
      var collapsedResults = collapse(reducedMatch.map((x) => x.requested));

      collapsedResults.forEach((path, i) {
        var reducedVirtualPath = reducedMatch[i].virtual;
        path.forEach((atom, index) {

          // If its not a routed atom then wholesale replace
          if (!isRoutedToken(reducedVirtualPath[index])) {
            reducedVirtualPath[index] = atom;
          }
        });

        collapsedMatched.add(reducedMatch[i]);
      });
    });

    return new PathMatch()
        ..matched = collapsedMatched
        ..missingPaths = missing;
  };
}

void match(Map<Keys, Map> curr, List path, String method, List matchedFunctions, List<List> missingPaths,
  [int depth = 0, List requested, List virtual, List precedence]) {
  if (curr == null) return;

  if (matchedFunctions == null) matchedFunctions = [];
  if (requested == null) requested = [];
  if (virtual == null) virtual = [];
  if (precedence == null) precedence = [];

  // At this point in the traversal we have hit a matching function.
  // Its time to terminate.
  // Get: simple method matching
  // Set/Call: The method is unique.  If the path is not complete,
  // meaning the depth is equivalent to the length,
  // then we match a 'get' method, else we match a 'set' or 'call' method.
  var atEndOfPath = path.length == depth;
  var isSet = method == 'set';
  var isCall = method == 'call';
  var methodToUse = method;
  if ((isCall || isSet) && !atEndOfPath) {
    methodToUse = 'get';
  }

  // Stores the matched result if found along or at the end of
  // the path.  If we are doing a set and there is no set handler
  // but there is a get handler, then we need to use the get
  // handler.  This is so that the current value that is in the
  // clients cache does not get materialized away.
  var currentMatch = curr[Keys.match];

  // From https://github.com/Netflix/falcor-router/issues/76
  // Set: When there is no set hander then we should default to running
  // the get handler so that we do not destroy the client local values.
  if (currentMatch != null && isSet && !currentMatch['set']) {
    methodToUse = 'get';
  }

  // Check to see if we have
  if (currentMatch != null && currentMatch[methodToUse] != null) {
    matchedFunctions.add({

      // Used for collapsing paths that use routes with multiple
      // string indexers.
      'id': currentMatch[methodToUse + 'Id'],
      'requested': new List.from(requested),

      'action': currentMatch[methodToUse],
      'authorize': currentMatch['authorize'],
      'virtual': new List.from(virtual),
      'precedence': int.parse(precedence.join('')),
      'suffix': path.sublist(depth),
      'isSet': atEndOfPath && isSet,
      'isCall': atEndOfPath && isCall
    });
  }

  var keySet = depth < path.length ? path[depth] : null;
  var i, key, next;

  // -------------------------------------------
  // Specific key matcher.
  // -------------------------------------------
  var specificKeys = specificMatcher(keySet, curr);
  for (i = 0; i < specificKeys.length; ++i) {
    key = specificKeys[i];
    virtual.add(key);
    requested.add(key);
    precedence.add(Precedence.specific);

    // Its time to recurse
    match(
        curr[specificKeys[i]],
        path, method, matchedFunctions,
        missingPaths, depth + 1,
        requested, virtual, precedence);

    // Removes the virtual, requested, and precedence info
    virtual.length = depth;
    requested.length = depth;
    precedence.length = depth;
  }

  var ints = pluckIntegers(keySet);
  var keys = keySet;

  // -------------------------------------------
  // ints, ranges, and keys matcher.
  // -------------------------------------------
  allTypes
    .where((typeAndPrecedence) {
      var type = typeAndPrecedence['type'];
      // one extra move required for int types
      if (type == Keys.integers || type == Keys.ranges) {
        return curr[type] != null && ints.isNotEmpty;
      }
      return curr[type] != null;
    })
    .forEach((typeAndPrecedence) {
      var type = typeAndPrecedence['type'];
      var prec = typeAndPrecedence['precedence'];
      next = curr[type];

      virtual.add({
        'type': type,
        'named': next[Keys.named],
        'name': next[Keys.name]
      });

      // The requested set of info needs to be set either
      // as ints, if int matchers or keys
      if (type == Keys.integers || type == Keys.ranges) {
        requested.add(ints);
      } else {
        requested.add(keys);
      }

      precedence.add(prec);

      // Continue the matching algo.
      match(
        next,
        path, method, matchedFunctions,
        missingPaths, depth + 1,
        requested, virtual, precedence);

      // removes the added keys
      virtual.length = depth;
      requested.length = depth;
      precedence.length = depth;
    });
}
