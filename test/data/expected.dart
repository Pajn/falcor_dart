library falcor_dart.expected.routes;

import 'package:falcor_dart/src/types/sentinels.dart';

expectedRoutes() {
  return {'Videos': videoExpectedRoutes()};
}

videoExpectedRoutes() {
  var retVal = {
    'Summary': {
      'jsonGraph': {
        'videos': {'summary': $atom(75)}
      }
    }
  };
  [0, 1, 2, 'someKey'].forEach((key) {
    retVal[key] = {'summary': generateSummary(key)};
  });
  retVal['state'] = {};
  [0, 1, 2, 'specificKey'].forEach((key) {
    retVal['state'][key] = generateState(key);
  });
  return retVal;
}

generateSummary(id) {
  var videos = {};
  videos[id] = {
    'summary': $atom({'title': 'Some Movie ' + id})
  };

  return {
    'jsonGraph': {videos: videos}
  };
}

generateState(id) {
  var videos = {'state': {}};
  videos['state'][id] = $atom({'title': 'Some State ' + id});

  return {
    'jsonGraph': {videos: videos}
  };
}
