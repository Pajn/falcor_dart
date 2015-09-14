import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/falcor_dart.dart';
import 'dart:async';

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
      var onNext = new SpyFunction('onNext');

      var value = await router.get([
        ["videos", 1, "title"]
      ]);
      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.getCall(0).args[0]).toEqual({
        'jsonGraph': {
          'videos': {
            '1': {r'$type': 'error', 'value': {}}
          }
        }
      });
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
      var onNext = new SpyFunction('onNext');
      var value = await router.get([
        [
          'videos',
          [1234, 333],
          'rating'
        ]
      ]);
      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.getCall(0).args[0]).toEqual({
        'jsonGraph': {
          'videos': {
            '1234': {
              'rating': {r'$type': 'error', 'value': {}}
            },
            '333': {
              'rating': {r'$type': 'error', 'value': {}}
            }
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
      var onNext = new SpyFunction('onNext');
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

      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.getCall(0).args[0]).toEqual({
        'jsonGraph': {
          'videos': {
            '1234': {
              'rating': {r'$type': "error", 'value': {}}
            },
            '333': {
              'rating': {r'$type': "error", 'value': {}}
            }
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
      var onNext = new SpyFunction('onNext');
      var routerSetValue = router.set({
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
      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.getCall(0).args[0]).toEqual({
        'jsonGraph': {
          'videos': {
            '1234': {
              'rating': {r'$type': "error", 'value': {}}
            },
            '333': {
              'rating': {r'$type': "error", 'value': {}}
            }
          }
        }
      });
    });
  });
}
