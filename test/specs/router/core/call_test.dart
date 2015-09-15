library falcor_dart.call_test.dart;

import 'dart:async';
import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/falcor_dart.dart';

main() {
  describe('Call', () {
    //todo(rasmus): this binding in Dart?
//    it('should bind "this" properly on a call that tranverses through a reference.',
//        () async {
//      var values = [];
//      var router = new Router([
//        {
//          'route': "genrelist.myList",
//          'get': (pathSet) {
//            values.add(this.testValue);
//            return [
//              {
//                'path': ['genrelist', 'myList'],
//                'value': $ref(['genrelist', 10])
//              }
//            ];
//          }
//        },
//        {
//          'route': 'genrelist[10].titles.push',
//          'call': (callPath, args) {
//            values.add(this.testValue);
//            return [
//              {
//                'path': ['genrelist', 10, 'titles', 100],
//                'value': "title100"
//              },
//              {
//                'path': ['genrelist', 10, 'titles', 'length'],
//                'value': 101
//              }
//            ];
//          }
//        }
//      ]);
//
//      router.testValue = 1;
//      var value = await router.call(
//          ['genrelist', 'myList', 'titles', 'push'], ["title100"]);
//      expect(value).toEqual([1, 1]);
//    });

    it('should return invalidations.', () async {
      var router = new Router([
        {
          'route': 'genrelist[{integers:indices}].titles.remove',
          'call': (callPath, args) {
            return callPath['indices'].fold([], (acc, genreIndex) {
              return acc
                ..addAll([
                  {
                    'path': [
                      'genrelist',
                      genreIndex,
                      'titles',
                      {'from': 2, 'to': 2}
                    ],
                    'invalidated': true
                  },
                  {
                    'path': ['genrelist', genreIndex, 'titles', 'length'],
                    'value': 2
                  }
                ]);
            });
          }
        }
      ]);

      var value = await router.call(['genrelist', 0, 'titles', 'remove'], [1]);
      expect(value).toEqual({
        "invalidated": [
          [
            "genrelist",
            0,
            "titles",
            {"from": 2, "to": 2}
          ]
        ],
        "jsonGraph": {
          "genrelist": {
            0: {
              "titles": {"length": 2}
            }
          }
        },
        "paths": [
          ["genrelist", 0, "titles", "length"]
        ]
      });
    });

    it('should onError when a Future.error of Error is returned from call.',
        () async {
      var router = new Router([
        {
          'route': 'videos[{integers:id}].rating',
          'call': (callPath, args) {
            return new Future.error(new Exception("Oops?"));
          }
        }
      ]);

      try {
        await router.call(['videos', 1234, 'rating'], [5]);
        throw 'should throw';
      } on Exception catch (e) {
        expect(e.toString()).toEqual('Exception: Oops?');
      }
    });

    it('should onError when an Error is thrown from call.', () async {
      var router = new Router([
        {
          'route': 'videos[{integers:id}].rating',
          'call': (callPath, args) {
            throw new Exception("Oops?");
          }
        }
      ]);

      try {
        await router.call(['videos', 1234, 'rating'], [5]);
        throw 'should throw';
      } on Exception catch (e) {
        expect(e.toString()).toEqual('Exception: Oops?');
      }
    });

    it('should return paths in jsonGraphEnvelope if route returns a promise of jsonGraphEnvelope with paths.',
        () async {
      var router = new Router([
        {
          'route': 'genrelist[{integers:indices}].titles.push',
          'call': (callPath, args) {
            return new Future.value({
              "jsonGraph": {
                "genrelist": {
                  "0": {
                    "titles": {
                      "18": $ref(["titlesById", 1]),
                      "length": 19
                    }
                  }
                }
              },
              "paths": [
                [
                  "genrelist",
                  0,
                  "titles",
                  ["18", "length"]
                ]
              ]
            });
          }
        }
      ]);

      var value = await router.call([
        'genrelist',
        0,
        'titles',
        'push'
      ], [
        $ref(['titlesById', 1])
      ], [], []);
      expect(value).toEqual({
        "jsonGraph": {
          "genrelist": {
            0: {
              "titles": {
                "18": $ref(['titlesById', 1]),
                "length": 19
              }
            }
          }
        },
        "paths": [
          [
            "genrelist",
            0,
            "titles",
            [18, "length"]
          ]
        ]
      });
    });

    //todo(rasmus): fix
    xit('should cause the router to on error only.', () async {
      getRouter(noPaths: true).call(['videos', 1234, 'rating'], [5]).doAction(
          () {
        throw new Exception('Should not be called.  onNext');
      }, (x) {
        expect(x.message).toEqual(errors.callJSONGraphWithouPaths);
      }, () {
        throw new Exception('Should not be called.  onCompleted');
      }).subscribe(noOp, (e) {
        if (e.message == errors.callJSONGraphWithouPaths) {
          done();
          return;
        }
        done(e);
      });
    });

    it('should return paths in jsonGraphEnvelope if array of pathValues is returned from promise.',
        () async {
      var router = new Router([
        {
          'route': 'genrelist[{integers:indices}].titles.push',
          'call': (callPath, args) {
            return new Future.value([
              {
                "path": ["genrelist", 0, "titles", 18],
                "value": $ref(["titlesById", 1])
              },
              {
                "path": ["genrelist", 0, "titles", "length"],
                "value": 19
              }
            ]);
          }
        }
      ]);

      var value = await router.call([
        'genrelist',
        0,
        'titles',
        'push'
      ], [
        $ref(['titlesById', 1])
      ], [], []);
      expect(value).toEqual({
        "jsonGraph": {
          "genrelist": {
            0: {
              "titles": {
                18: $ref(["titlesById", 1]),
                "length": 19
              }
            }
          }
        },
        "paths": [
          [
            "genrelist",
            0,
            "titles",
            [18, "length"]
          ]
        ]
      });
    });

    it('should perform a simple call.', () async {
      var value = await getRouter().call(['videos', 1234, 'rating'], [5]);
      expect(value).toEqual({
        'jsonGraph': {
          'videos': {
            1234: {'rating': 5}
          }
        },
        'paths': [
          ['videos', 1234, 'rating']
        ]
      });
    });

    it('should pass the #30 base call test with only suffix.', () async {
      var value = await getExtendedRouter().call([
        'lolomo',
        'pvAdd'
      ], [
        'Thrillers'
      ], [
        ['name']
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'lolomo': $ref('lolomos[123]'),
          'lolomos': {
            123: {0: $ref('listsById[0]')}
          },
          'listsById': {
            0: {'name': 'Thrillers'}
          }
        },
        'paths': [
          ['lolomo', 0, 'name']
        ]
      });
    });

    it('should pass the #30 base call test with only paths.', () async {
      var jsongEnv = await getExtendedRouter().call(
          ['lolomo', 'pvAdd'],
          ['Thrillers'],
          null,
          [
            ['length']
          ]);
      expect(jsongEnv).toEqual({
        'jsonGraph': {
          'lolomo': $ref('lolomos[123]'),
          'lolomos': {
            123: {0: $ref('listsById[0]'), 'length': 1}
          }
        },
        'paths': [
          ['lolomo', 'length'],
          ['lolomos', 123, 0]
        ]
      });
    });

    it('should pass the #30 base call test with both paths and suffixes.',
        () async {
      var jsongEnv = await getExtendedRouter().call([
        'lolomo',
        'pvAdd'
      ], [
        'Thrillers'
      ], [
        ['name']
      ], [
        ['length']
      ]);
      expect(jsongEnv).toEqual({
        'jsonGraph': {
          'lolomo': $ref('lolomos[123]'),
          'lolomos': {
            123: {0: $ref('listsById[0]'), 'length': 1}
          },
          'listsById': {
            0: {'name': 'Thrillers'}
          }
        },
        'paths': [
          ['lolomo', 'length'],
          ['lolomo', 0, 'name']
        ]
      });
    });

    it('should allow item to be pushed onto collection.', () async {
      var value = await getCallRouter().call([
        'genrelist',
        0,
        'titles',
        'push'
      ], [
        $ref(['titlesById', 1])
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'genrelist': {
            0: {
              'titles': {
                2: $ref(['titlesById', 1])
              }
            }
          }
        },
        'paths': [
          ['genrelist', 0, 'titles', 2]
        ]
      });
    });

    it('should evaluate path suffixes on result of a function that adds an item to a collection.',
        () async {
      var value = await getCallRouter().call([
        'genrelist',
        0,
        'titles',
        'push'
      ], [
        $ref(['titlesById', 1])
      ], [
        ['name'],
        ['rating']
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'genrelist': {
            0: {
              'titles': {
                2: $ref(['titlesById', 1])
              }
            }
          },
          'titlesById': {
            1: {'name': 'Orange is the new Black', 'rating': 5}
          }
        },
        'paths': [
          [
            'genrelist',
            0,
            'titles',
            2,
            ['name', 'rating']
          ]
        ]
      });
    });

    it('should throw when calling a function that does not exist.', () async {
      var router = new Router([]);
      try {
        await router.call(['videos', 1234, 'rating'], [5]);
        throw 'should throw';
      } on Exception catch (e) {
        expect(e.toString()).toEqual('Exception: function does not exist');
      }
    });

    it('should throw when calling a function that does not exist, but get handler does.',
        () async {
      var router = new Router([
        {'route': 'videos[1234].rating', 'get': () {}}
      ]);
      try {
        await router.call(['videos', 1234, 'rating'], [5]);
        throw 'should throw';
      } on Exception catch (e) {
        expect(e.toString()).toEqual('Exception: function does not exist');
      }
    });
  });
}

Router getCallRouter() {
  return new Router([
    {
      'route': 'genrelist[{integers}].titles.push',
      'call': (callPath, args) {
        return {
          'path': ['genrelist', 0, 'titles', 2],
          'value': $ref(['titlesById', 1])
        };
      }
    },
    {
      'route': 'genrelist[{integers}].titles[{integers}]',
      'get': (pathSet) {
        return {
          'path': ['genrelist', 0, 'titles', 1],
          'value': $ref(['titlesById', 1])
        };
      }
    },
    {
      'route': 'titlesById[{integers}]["name", "rating"]',
      'get': (pathSet) {
        return [
          {
            'path': ['titlesById', 1, 'name'],
            'value': 'Orange is the new Black'
          },
          {
            'path': ['titlesById', 1, 'rating'],
            'value': 5
          }
        ];
      }
    }
  ]);
}

Router getRouter({bool noPaths: false, bool throwError: false}) {
  return new Router([
    {
      'route': 'videos[{integers:id}].rating',
      'call': (callPath, args) {
        if (throwError) {
          throw new Exception('Oops?');
        }
        return {
          'jsonGraph': {
            'videos': {
              1234: {'rating': args[0]}
            }
          },
          'paths': noPaths
              ? null
              : [
                  ['videos', 1234, 'rating']
                ]
        };
      }
    }
  ]);
}

Router getExtendedRouter([Map initialIdsAndNames]) {
  var listsById = {};
  var idsAndNames = initialIdsAndNames ?? {};
  idsAndNames.keys.fold(listsById, (acc, id) {
    var name = idsAndNames[id];
    listsById[id] = {'name': name, 'rating': 3};
    return acc;
  });

  listsLength() {
    return listsById.keys.length;
  }

  addToList(name) {
    var length = listsLength();
    listsById[length] = {'name': name, 'rating': 5};

    return length;
  }

  return new Router([
    {
      'route': 'lolomo',
      'get': (_) {
        return {
          'path': ['lolomo'],
          'value': $ref('lolomos[123]')
        };
      }
    },
    {
      'route': 'lolomos[{keys:ids}][{integers:indices}]',
      'get': (alias) {
        var id = alias.ids[0];
        return alias.indices.map((idx) {
          if (listsById[idx]) {
            return {
              'path': ['lolomos', id, idx],
              'value': $ref(['listsById', idx])
            };
          }
          return {
            'path': ['lolomos', id],
            'value': $atom(null)
          };
        });
      }
    },
    {
      'route': 'lolomos[{keys:ids}].length',
      'get': (alias) {
        var id = alias['ids'][0];
        return {
          'path': ['lolomos', id, 'length'],
          'value': listsLength()
        };
      }
    },
    {
      'route': 'listsById[{integers:indices}].name',
      'get': (alias) {
        return alias['indices'].map((idx) {
          if (listsById[idx] != null) {
            return {
              'path': ['listsById', idx, 'name'],
              'value': listsById[idx]['name']
            };
          }
          return {
            'path': ['listsById', idx],
            'value': $atom(null)
          };
        });
      }
    },
    {
      'route': 'listsById[{integers:indices}].invalidate',
      'call': (alias, args) {
        var indices = alias.indices;
        return indices.map((idx) {
          return {
            'path': ['listsById', idx, 'name']
          };
        });
      }
    },
    {
      'route': 'listsById[{integers:indices}].rating',
      'get': (alias) {
        return alias.indices.map((idx) {
          if (listsById[idx]) {
            return {
              'path': ['listsById', idx, 'rating'],
              'value': listsById[idx].rating
            };
          }
          return {
            'path': ['listsById', idx],
            'value': $atom(null)
          };
        });
      }
    },
    {
      'route': 'lolomos[{keys:ids}].pvAdd',
      'call': (callPath, args) {
        var id = callPath['ids'][0];
        var idx = addToList(args[0]);
        return {
          'path': ['lolomos', id, idx],
          'value': $ref(['listsById', idx])
        };
      }
    },
    {
      'route': 'lolomos[{keys:ids}].jsongAdd',
      'call': (callPath, args) {
        var id = callPath['ids'][0];
        var idx = addToList(args[0]);
        var lolomos = {};
        lolomos[id] = {};
        lolomos[id][idx] = $ref(['listsById', idx]);
        return {
          'jsonGraph': {'lolomos': lolomos},
          'paths': [
            ['lolomos', id, idx]
          ]
        };
      }
    }
  ]);
}
