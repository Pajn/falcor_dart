library falcor_dart.run_set_action;

outerRunSetAction(routerInstance, modelContext,
                  jsongCache) {
  return function innerRunSetAction(matchAndPath) {
    return runSetAction(routerInstance, modelContext,
    matchAndPath, jsongCache);
  };
};

function runSetAction(routerInstance, jsongMessage, matchAndPath, jsongCache) {
  var match = matchAndPath.match;
  var out;
  var arg = matchAndPath.path;

  // We are at out destination.  Its time to get out
  // the pathValues from the
  if (match.isSet) {
    var paths = spreadPaths(jsongMessage.paths);

    // We have to ensure that the paths maps in order
    // to the optimized paths array.
    var optimizedPaths =
    paths.
    // Optimizes each path.
    map(function(path) {
    return optimizePathSets(
    jsongCache, [path], routerInstance.maxRefFollow)[0];
    }).
    // only includes the paths from the set that intersect
    // the virtual path
    filter(function(path) {
    return hasIntersection(path, match.virtual);
    });

    // Constructs the json that is the set request virtual path.
    arg = paths.
    reduce(function(json, path, i) {
    pathValueMerge(json, {
    path: optimizedPaths[i],
    value: getValue(jsongMessage.jsonGraph, path)
    });
    return json;
    }, {});
  }
  out = match.action.call(routerInstance, arg);
  out = outputToObservable(out);

  return authorize(routerInstance, match, out).
  materialize().
  filter(function(note) {
  return note.kind !== 'C';
  }).
  map(noteToJsongOrPV(matchAndPath));
}
