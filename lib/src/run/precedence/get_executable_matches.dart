library falcor_dart.run.precendence.get_executable_matches;


/// takes in the set of ordered matches and pathSet that got those matches.
/// From there it will give back a list of matches to execute.
List getExecutableMatches(List matches, List pathSet) {
  var remainingPaths = pathSet;
  var matchAndPaths = [];
  for (var i = 0; i < matches.length && remainingPaths.length > 0; ++i) {
    var availablePaths = remainingPaths;
    var match = matches[i];

    remainingPaths = [];

    if (i > 0) {
      availablePaths = collapse(availablePaths);
    }

    // For every available path attempt to intersect.  If there
    // is an intersection then strip and replace.
    // any relative complements, add to remainingPaths
    for (var j = 0; j < availablePaths.length; ++j) {
      var path = availablePaths[j];
      if (hasIntersection(path, match.virtual)) {
        var stripResults = stripPath(path, match.virtual);
        matchAndPaths[matchAndPaths.length] = {
          path: stripResults[0],
          match: match
        };
        remainingPaths = remainingPaths.concat(stripResults[1]);
      }
    }
  }

  return matchAndPaths;
}
