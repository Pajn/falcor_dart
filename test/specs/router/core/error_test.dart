import 'dart:async';
import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/falcor_dart.dart';
import 'package:falcor_dart/src/exceptions.dart';

main() {
  describe('Error', () {
    it('should return an empty error when throwing a non error.', () async {
      var router = new Router([
        {
          'route': 'videos[{integers:ids}]',
          'get': (alias) {
            throw 'hello world';
          }
        }
      ]);

      var value = await router.get([
        ["videos", 1, "title"]
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'videos': {1: $error({})}
        }
      });
    });

    it('should throw an error when maxExpansion has been exceeded.', () async {
      var router = new Router([
        {
          'route': 'videos[{integers:ids}]',
          'get': (alias) {
            return {
              'path': ['videos', 1],
              'value': $ref('videos[1]')
            };
          }
        }
      ]);

      try {
        await router.get([
          ["videos", 1, "title"]
        ]);
        throw 'Should have thrown a CircularReferenceError';
      } on CircularReferenceError catch (_) {}
    });

    it('thrown non-Error should insert in the value property of error object for all requested paths.',
        () async {
      var router = new Router([
        {
          'route': 'videos[{integers:id}].rating',
          'get': (json) {
            throw {'message': 'not authorized', 'unauthorized': true};
          }
        }
      ]);
      var value = await router.get([
        [
          'videos',
          [1234, 333],
          'rating'
        ]
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'videos': {
            1234: {'rating': $error({})},
            333: {'rating': $error({})}
          }
        }
      });
    });

    it('promise rejection of non Error should insert object as the value property within an error for all requested paths (either being set or get).',
        () async {
      var router = new Router([
        {
          'route': 'videos[{integers:id}].rating',
          'set': (json) {
            return new Future.error(
                {'message': 'user not authorized', 'unauthorized': true});
          }
        }
      ]);
      var routerSetValue = await router.set({
        'jsonGraph': {
          'videos': {
            '1234': {'rating': 5},
            '333': {'rating': 5}
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

      expect(routerSetValue).toEqual({
        'jsonGraph': {
          'videos': {
            1234: {'rating': $error({})},
            333: {'rating': $error({})}
          }
        }
      });
    });

    it('thrown non-Error should insert in the value property of error object for all requested paths (either being set or get).',
        () async {
      var router = new Router([
        {
          'route': 'videos[{integers:id}].rating',
          'set': (json) {
            throw {'message': 'not authorized', 'unauthorized': true};
          }
        }
      ]);
      var routerSetValue = await router.set({
        'jsonGraph': {
          'videos': {
            '1234': {'rating': 5},
            '333': {'rating': 5}
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
      expect(routerSetValue).toEqual({
        'jsonGraph': {
          'videos': {
            1234: {'rating': $error({})},
            333: {'rating': $error({})}
          }
        }
      });
    });
  });
}
