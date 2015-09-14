import 'package:falcor_dart/src/types/sentinels.dart';
import 'package:falcor_dart/falcor_dart.dart';

import '../testrunner.dart';

routes() {
  return {'Videos': videoRoutes(), 'GenreLists': genreListsRoutes()};
}

videoRoutes() {
  return {
    'Summary': (fn) {
      return [
        {
          'route': 'videos.summary',
          'get': (path) {
            fn && fn(path);
            return {
              'jsonGraph': {
                'videos': {'summary': $atom(75)}
              },
              'paths': [
                ['videos', 'summary']
              ]
            };
          }
        }
      ];
    },
    'Keys': {
      'Summary': (fn) {
        return [
          {
            'route': 'videos[{keys}].summary',
            'get': (path) {
              if (fn != null) {
                fn(path);
              }
              return path[1].map((id) {
                return generateVideoJSONG(id);
              });
            }
          }
        ];
      }
    },
    'Integers': {
      'Summary': (fn) {
        return [
          {
            'route': ['videos', Keys.integers, 'summary'],
            'get': (path) {
              if (fn != null) {
                fn(path);
              }
              return path[1].map((id) {
                return generateVideoJSONG(id);
              });
            }
          }
        ];
      }
    },
    'Ranges': {
      'Summary': (fn) {
        return [
          {
            'route': ['videos', Keys.ranges, 'summary'],
            'get': (path) {
              if (fn != null) {
                fn(path);
              }
              return TestRunner.rangeToArray(path[1]).map((id) {
                return generateVideoJSONG(id);
              });
            }
          }
        ];
      }
    },
    'State': {
      'Keys': (fn) {
        return [
          {
            'route': ['videos', 'state', R.keys],
            'get': (path) {
              if (fn != null) {
                fn(path);
              }
              return path[2].map((key) {
                return generateVideoStateJSONG(key);
              });
            }
          }
        ];
      },
      'Integers': (fn) {
        return [
          {
            'route': ['videos', 'state', Keys.integers],
            'get': (path) {
              if (fn != null) {
                fn(path);
              }
              return path[2].map((key) {
                return generateVideoStateJSONG(key);
              });
            }
          }
        ];
      },
      'Ranges': (fn) {
        return [
          {
            'route': ['videos', 'state', Keys.ranges],
            'get': (path) {
              if (fn != null) {
                fn(path);
              }
              return TestRunner.rangeToArray(path[2]).map((key) {
                return generateVideoStateJSONG(key);
              });
            }
          }
        ];
      }
    }
  };
}

genreListsRoutes() {
  return {
    'Integers': (fn) {
      return [
        {
          'route': 'genreLists[{ranges:indices}]',
          'get': (path) {
            if (fn) {
              fn(path);
            }
            var genreLists = {};
            TestRunner.rangeToArray(path.indices).forEach((x) {
              genreLists[x] = $ref(['videos', x]);
            });
            return {
              'jsonGraph': {'genreLists': genreLists}
            };
          }
        }
      ];
    }
  };
}

generateVideoJSONG(id) {
  var videos;
  var jsongEnv = {
    'jsonGraph': {'videos': (videos = {})},
    'paths': [
      ['videos', id, 'summary']
    ]
  };
  videos[id] = {
    'summary': $atom({'title': 'Some Movie $id'})
  };

  return jsongEnv;
}

generateVideoStateJSONG(id) {
  var videos;
  var jsongEnv = {
    'jsonGraph': {
      'videos': (videos = {'state': {}})
    },
    'paths': [
      ['videos', 'state', id]
    ]
  };
  videos['state'][id] = $atom({'title': 'Some State $id'});

  return jsongEnv;
}
