import 'package:guinness2/guinness2.dart';

import 'package:falcor_dart/router.dart';
import '../../../data/routes.dart';
import 'package:test/test.dart' show expectAsync;

main() {
  describe('Set', () {
    xit('should not transform set values before passing them to route. (undefined)',
        () {
      var router = new Router([
        route('titlesById[{integers:titleIds}].userRating', set: (json) {
          var exception = false;
          try {
            expect(json.titlesById[1].keys).toContain('userRating');
            expect(json.titlesById[1]).toBeNull();
          } catch (e) {
            exception = true;
          }
          if (!exception) {
            return;
          }
        }),
      ]);

      router.set({
        'jsonGraph': {
          'titlesById': {
            '1': {'userRating': null}
          }
        },
        'paths': [
          ['titlesById', 1, 'userRating']
        ]
      });
    });

    xit('should call the route when setting a value to null', () {
      var called = false;
      var router = new Router([
        route('titlesById[{integers:titleIds}].userRating', set: (json) {
          called = true;
          var exception = false;
          try {
            expect(json).toEqual({
              'titlesById': {
                '1': {'userRating': null}
              }
            });
          } catch (e) {
            exception = true;
          }
          if (!exception) {
            return;
          }
        }),
      ]);

      router.set({
        'jsonGraph': {
          'titlesById': {
            '1': {'userRating': null}
          }
        },
        'paths': [
          ['titlesById', 1, 'userRating']
        ]
      });
      expect(called).toEqual(true);
    });

    xit('should call get() with the same type of arguments when no route for set() found.',
        () {
      var router = new Router([
        route('titlesById[{integers:titleIds}].rating', get: (pathSet) {
          var exception = false;
          try {
            expect(pathSet).toEqual([
              'titlesById',
              [0],
              'rating'
            ]);
          } catch (e) {
            exception = true;
          }
          if (!exception) {
            return;
          }
        }),
      ]);

      router.set({
        'jsonGraph': {
          'titlesById': {
            '0': {'rating': 5}
          }
        },
        'paths': [
          ['titlesById', 0, 'rating']
        ]
      });
    });

    xit('should not transform set values before passing them to route. (0)',
        () {
      var router = new Router([
        {
          'route': 'titlesById[{integers:titleIds}].userRating',
          'set': (json) {
            var exception = false;
            try {
              expect(json).toEqual({
                'titlesById': {
                  '1': {'userRating': 0}
                }
              });
            } catch (e) {
              exception = true;
            }
            if (!exception) {
              return;
            }
          }
        }
      ]);

      router.set({
        'jsonGraph': {
          'titlesById': {
            '1': {'userRating': 0}
          }
        },
        'paths': [
          ['titlesById', 1, 'userRating']
        ]
      });
    });

    xit('should not transform set values before passing them to route.  ("")',
        () {
      var router = new Router([
        {
          'route': 'titlesById[{integers:titleIds}].userRating',
          'set': (json) {
            var exception = false;
            try {
              expect(json).toEqual({
                'titlesById': {
                  '1': {'userRating': ''}
                }
              });
            } catch (e) {
              exception = true;
            }
            if (!exception) {
              return;
            }
          }
        }
      ]);

      router.set({
        'jsonGraph': {
          'titlesById': {
            '1': {'userRating': ''}
          }
        },
        'paths': [
          ['titlesById', 1, 'userRating']
        ]
      });
    });

    it('should perform a simple set.', () async {
      var router = new Router([
        route('videos[{integers:id}].rating', set: (json) {
          expect(json).toEqual({
            'videos': {
              1234: {'rating': 5},
              333: {'rating': 5},
            }
          });
          return [
            {
              'path': ['videos', 1234, 'rating'],
              'value': 5
            },
            {
              'path': ['videos', 333, 'rating'],
              'value': 5
            }
          ];
        }),
      ]);
      var value = await router.set({
        'jsonGraph': {
          'videos': {
            1234: {'rating': 5},
            333: {'rating': 5},
          }
        },
        'paths': [
          [
            'videos',
            [1234, 333],
            'rating'
          ]
        ]
      });
      expect(value).toEqual({
        'jsonGraph': {
          'videos': {
            1234: {'rating': 5},
            333: {'rating': 5}
          }
        }
      });
    });

    it('should ensure that set gets called with only the data it needs.',
        () async {
      var setSpy = new SpyFunction('set').andCallFake((jsonGraph) {
        return {'jsonGraph': jsonGraph};
      });
      var router = new Router([
        route('titlesById[{integers:titleIds}].userRating', set: setSpy),
        route('genreLists[{integers:titleIds}]', get: (pathSet) {
          var id = pathSet['titleIds'][0];
          return {
            'path': ['genreLists', id],
            'value': $ref(['titlesById', id])
          };
        }),
      ]);

      var value = await router.set({
        "jsonGraph": {
          "genreLists": {
            9: {"userRating": 9},
            10: {"userRating": 10}
          }
        },
        "paths": [
          ["genreLists", 9, "userRating"],
          ["genreLists", 10, "userRating"]
        ]
      });
      expect(setSpy.calls.length).toEqual(2);
      expect(setSpy.calls[0].positionalArguments[0]).toEqual({
        "titlesById": {
          9: {"userRating": 9}
        }
      });
      expect(setSpy.calls[1].positionalArguments[0]).toEqual({
        "titlesById": {
          10: {"userRating": 10}
        }
      });
      expect(value).toEqual({
        "jsonGraph": {
          "genreLists": {9: $ref('titlesById[9]'), 10: $ref('titlesById[10]')},
          "titlesById": {
            10: {"userRating": 10},
            9: {"userRating": 9}
          }
        }
      });
    });

    it('should perform a set with get reference following.', () async {
      var called = 0;
      var refFollowed = false;
      var router = new Router(routes()['Genrelists']['Integers']((_) {
        refFollowed = true;
      })
        ..addAll([
          route('videos[{integers:id}].rating', set: (json) {
            called++;
            try {
              expect(json).toEqual({
                'videos': {
                  0: {'rating': 5}
                }
              });
            } catch (e) {
              print(e);
              expect('did throw').toEqual('not throw');
            }
            return [
              {
                'path': ['videos', 0, 'rating'],
                'value': 5
              }
            ];
          }),
        ]));

      var value = await router.set({
        'jsonGraph': {
          'genreLists': {
            0: {'rating': 5}
          }
        },
        'paths': [
          ['genreLists', 0, 'rating']
        ]
      });
      expect(value).toEqual({
        'jsonGraph': {
          'genreLists': {0: $ref('videos[0]')},
          'videos': {
            0: {'rating': 5}
          }
        }
      });

      expect(called).toEqual(1);
      expect(refFollowed).toBeTrue();
    });

    it('should invoke getter on attempt to set read-only property.', () async {
      var router = new Router([
        route('a.b.c',
            get: (_) => {
                  'path': ['a', 'b', 'c'],
                  'value': 5
                }),
      ]);
      var value = await router.set({
        'paths': [
          ['a', 'b', 'c']
        ],
        'jsonGraph': {
          'a': {
            'b': {'c': 7}
          }
        }
      });
      expect(value).toEqual({
        'jsonGraph': {
          'a': {
            'b': {'c': 5}
          }
        }
      });
    });
  });
}
