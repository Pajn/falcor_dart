library falcor_dart.run_call_action;

import 'dart:async';
import 'package:falcor_dart/src/run/run_get_action.dart';
import 'package:falcor_dart/src/utils.dart';
import 'package:falcor_dart/src/router.dart';
import 'package:falcor_dart/src/path_set.dart';
import 'package:falcor_dart/src/run/merge_cache_and_gather_refs_and_invalidations.dart';
import 'package:falcor_dart/src/exceptions.dart';

ActionRunner runCallAction(Router routerInstance, List callPath, List args,
    List suffixes, List<PathSet> paths, Map jsongCache) {
  return (matchAndPath) {
    return innerRunCallAction(matchAndPath, routerInstance, callPath, args,
        suffixes, paths, jsongCache);
  };
}

Future innerRunCallAction(
    Map matchAndPath,
    Router routerInstance,
    List callPath,
    List args,
    List suffixes,
    List<PathSet> paths,
    Map jsongCache) async {
  Map match = matchAndPath['match'];
  var matchedPath = matchAndPath['path'];

  // We are at out destination.  Its time to get out
  // the pathValues from the
  if (match['isCall']) {
    // This is where things get interesting
    var result;
    try {
      result = [await match['action'](matchedPath, args)];
    } catch (error) {
      rethrow;
      return [convertNoteToJsongOrPV(matchAndPath, error, error: true)];
    }
    // Required to get the references from the outputting jsong
    // and pathValues.
    // checks call for isJSONG and if there is jsong without paths
    // throw errors.
    var refs = [];
    var values = [];

    // Will flatten any arrays of jsong/pathValues.
    var callOutput = result.fold([], (flattenedRes, next) {
      if (next is List) {
        return flattenedRes..addAll(next);
      } else {
        return flattenedRes..add(next);
      }
    });

    callOutput.forEach((r) {
      // its json graph.
      if (isJSONG(r)) {
        // This is a hard error and must fully stop the server
        if (r['paths'] == null) {
          throw new CallJsonGraphWithoutPaths();
        }
      }
    });

    var invsRefsAndValues =
        mergeCacheAndGatherRefsAndInvalidations(jsongCache, callOutput);

    refs.addAll(invsRefsAndValues['references']);

    values = invsRefsAndValues['values'].map((pv) {
      return pv['path'];
    });

    var callPathSave1 = callPath.sublist(0, callPath.length - 1);
    var hasSuffixes = suffixes != null && suffixes.isNotEmpty;
    var hasPaths = paths != null && paths.isNotEmpty;

    // We are going to use recurseMatchAndExecute to run
    // the paths and suffixes for call.  For that to happen
    // we must send a message to the outside to switch from
    // call to get.
    callOutput.add({'isMessage': true, 'method': 'get'});

    // If there are paths to add then push them into the next
    // paths through 'additionalPaths' message.
    if (hasPaths) {
      paths.forEach((path) {
        callOutput.add({
          'isMessage': true,
          'additionalPath': new List.from(callPathSave1)..addAll(path)
        });
      });
    }

    // Suffix is the same as paths except for how to calculate
    // a path per reference found from the callPath.
    if (hasSuffixes) {
      // matchedPath is the optimized path to call.
      // e.g:
      // callPath: [genreLists, 0, add] ->
      // matchedPath: [lists, 'abc', add]
      var optimizedPathLength = matchedPath.length - 1;

      // For every reference build the complete path
      // from the callPath - 1 and concat remaining
      // path from the PathReference (path is where the
      // reference was found, not the value of the reference).
      // e.g: from the above example the output is:
      // output = {path: [lists, abc, 0], value: [titles, 123]}
      //
      // This means the refs object = [output];
      // callPathSave1: [genreLists, 0],
      // optimizedPathLength: 3 - 1 = 2
      // ref.path.slice(2): [lists, abc, 0].slice(2) = [0]
      // deoptimizedPath: [genreLists, 0, 0]
      //
      // Add the deoptimizedPath to the callOutput messages.
      // This will make the outer expand run those as a 'get'
      refs.forEach((ref) {
        var deoptimizedPath = new List.from(callPathSave1)
          ..addAll(ref['path'].sublist(optimizedPathLength));
        suffixes.forEach((suffix) {
          var additionalPath = new List.from(deoptimizedPath)..addAll(suffix);
          callOutput.add({'isMessage': true, 'additionalPath': additionalPath});
        });
      });
    }

    // If there are no suffixes but there are references, report
    // the paths to the references.  There may be values as well,
    // add those to the output.
    if (refs.isNotEmpty && !hasSuffixes || values.isNotEmpty) {
      var additionalPaths = [];
      if (refs.isNotEmpty && !hasSuffixes) {
        additionalPaths = refs.map((x) {
          return x['path'];
        }).toList();
      }
      additionalPaths
        ..addAll(values)
        ..forEach((path) {
          callOutput.add({'isMessage': true, 'additionalPath': path});
        });
    }

    return [callOutput].map(noteToJsongOrPV(matchAndPath));

    // When call has an error it needs to be propagated to the next
    // level instead of onCompleted'ing
//        do(null, (e) {
//      e.throwToNext = true;
//      throw e;
//    });
  } else {
    try {
      var matchAction = await match['action'](matchAndPath['path']);

      if (matchAction is! Iterable) {
        matchAction = [matchAction];
      }

      return matchAction.map(noteToJsongOrPV(matchAndPath));
    } catch (error) {
      rethrow;
      return [convertNoteToJsongOrPV(matchAndPath, error, error: true)];
    }
  }
}
