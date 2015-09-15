import 'package:guinness2/guinness2.dart';

import 'package:falcor_dart/falcor_dart.dart';

main() {
  describe('Set', () {
    xit('should not transform set values before passing them to route. (undefined)',
        () {
      var router = new Router([
        {
          'route': 'titlesById[{integers:titleIds}].userRating',
          'set': (json) {
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
          }
        }
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
        {
          'route': 'titlesById[{integers:titleIds}].userRating',
          'set': (json) {
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
          }
        }
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
        {
          'route': 'titlesById[{integers:titleIds}].rating',
          'get': (json) {
            var exception = false;
            try {
              expect(json).toEqual([
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
          }
        }
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
        {
          'route': 'videos[{integers:id}].rating',
          'set': (json) {
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
          }
        }
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
  });
}
