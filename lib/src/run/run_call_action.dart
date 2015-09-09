library falcor_dart.run_call_action;

import 'package:falcor_dart/src/run/run_get_action.dart';
import 'package:falcor_dart/src/utils.dart';

runCallAction(routerInstance, callPath, args,
    suffixes, paths, jsongCache) {
  return (matchAndPath) {
    return innerRunCallAction(matchAndPath, routerInstance, callPath,
        args, suffixes, paths, jsongCache);
  };
}

innerRunCallAction(matchAndPath, routerInstance, callPath, args,
    suffixes, paths, jsongCache) {

  var match = matchAndPath.match;
  var matchedPath = matchAndPath.path;
  var out;

  // We are at out destination.  Its time to get out
  // the pathValues from the
  if (match.isCall) {

    // This is where things get interesting
    out = Observable.
    defer(() {
    var next;
    try {
    next = match.
    action.call(
    routerInstance, matchedPath, args, suffixes, paths);
    } catch (e) {
    e.throwToNext = true;
    throw e;
    }
    return outputToStream(next).
    toArray();
    }).

    // Required to get the references from the outputting jsong
    // and pathValues.
    map((res) {
    // checks call for isJSONG and if there is jsong without paths
    // throw errors.
    var refs = [];
    var values = [];

    // Will flatten any arrays of jsong/pathValues.
    var callOutput = res.reduce(function(flattenedRes, next) {
      return flattenedRes.concat(next);
    }, []);

var refLen = -1;
callOutput.forEach((r) {

  // its json graph.
  if (isJSONG(r)) {

    // This is a hard error and must fully stop the server
    if (!r.paths) {
      var err =
      new Exception(errors.callJSONGraphWithouPaths);
//      err.throwToNext = true;
      throw err;
    }
  }

});

var invsRefsAndValues = mCGRI(jsongCache, callOutput);
invsRefsAndValues.references.forEach((ref) {
  refs[++refLen] = ref;
});

values = invsRefsAndValues.values.map((pv) {
  return pv.path;
});

var callLength = callOutput.length;
var callPathSave1 = callPath.slice(0, callPath.length - 1);
var hasSuffixes = suffixes && suffixes.length;
var hasPaths = paths && paths.length;

// We are going to use recurseMatchAndExecute to run
// the paths and suffixes for call.  For that to happen
// we must send a message to the outside to switch from
// call to get.
callOutput[++callLength] = {'isMessage': true, 'method': 'get'};

// If there are paths to add then push them into the next
// paths through 'additionalPaths' message.
if (hasPaths && (callLength + 1)) {
paths.forEach((path) {
callOutput[++callLength] = {
'isMessage': true,
'additionalPath': callPathSave1.concat(path)
};
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
var deoptimizedPath = callPathSave1.concat(
ref.path.slice(optimizedPathLength));
suffixes.forEach((suffix) {
var additionalPath =
deoptimizedPath.concat(suffix);
callOutput[++callLength] = {
'isMessage': true,
'additionalPath': additionalPath
};
});
});
}

// If there are no suffixes but there are references, report
// the paths to the references.  There may be values as well,
// add those to the output.
if (refs.length && !hasSuffixes || values.length) {
var additionalPaths = [];
if (refs.length && !hasSuffixes) {
additionalPaths = refs.
map((x) { return x.path; });
}
additionalPaths.
concat(values).
forEach((path) {
callOutput[++callLength] = {
'isMessage': true,
'additionalPath': path
};
});
}

return callOutput;
}).

// When call has an error it needs to be propagated to the next
// level instead of onCompleted'ing
do(null, function(e) {
  e.throwToNext = true;
  throw e;
});
} else {
out = match.action.call(routerInstance, matchAndPath.path);
out = outputToObservable(out);
}

return out.
materialize().
filter((note) {
  return note.kind != 'C';
}).
map(noteToJsongOrPV(matchAndPath));
}
