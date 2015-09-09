import 'package:guinness2/guinness2.dart';

import 'package:falcor_dart/falcor_dart.dart';

import '../../../data/routes.dart';
import '../../../testrunner.dart';
import '../../../data/expected.dart';

main() {
  describe('Integers', () {
    it('should match integers for videos with int keys passed in.', () {
      var router =
          new Router(routes()['Videos']['Integers']['Summary']((pathSet) {
        TestRunner.comparePath([
          'videos',
          [1],
          'summary'
        ], pathSet);
      }));
      var obs = router.get([
        ['videos', 1, 'summary']
      ]);

      TestRunner.run(obs, [expectedRoutes()['Videos'][1]['summary']]);
    });

    it('should match integers for videos with array of ints passed in.', () {
      var router = new Router(routes()['Videos']['Integers']['Summary']((pathSet) {
        TestRunner.comparePath([
          'videos',
          [1, 2],
          'summary'
        ], pathSet);
      }));
      var obs = router.get([
        [
          'videos',
          [1, 2],
          'summary'
        ]
      ]);

      TestRunner.run(obs, [
        expectedRoutes()['Videos'][1]['summary'],
        expectedRoutes()['Videos'][2]['summary'],
      ]);
    });

    it('should match integers for videos with range passed in.', () {
      var router = new Router(routes()['Videos']['Integers']['Summary']((pathSet) {
        TestRunner.comparePath([
          'videos',
          [0, 1],
          'summary'
        ], pathSet);
      }));
      var obs = router.get([
        [
          'videos',
          {'to': 1},
          'summary'
        ]
      ]);

      TestRunner.run(obs, [
        expectedRoutes()['Videos'][0]['summary'],
        expectedRoutes()['Videos'][1]['summary'],
      ]);
    });

    it('should match integers as last key.', () {
      var router = new Router(routes()['Videos']['State']['Integers']((pathSet) {
        TestRunner.comparePath([
          'videos',
          'state',
          [0]
        ], pathSet);
      }));
      var obs = router.get([
        ['videos', 'state', 0]
      ]);

      TestRunner.run(obs, [expectedRoutes()['Videos']['state'][0]]);
    });

    it('should match ranges with integers pattern and coerce match into an array of integers.',
        () async {
      var onNext = new SpyFunction('onNext');
      var router = new Router([
        {
          'route': 'titlesById[{integers}]["name", "rating"]',
          'get': () {
            print('inside get');
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

      var value = await router.get([
        [
          'titlesById',
          {'from': 1, 'to': 1},
          ["name", "rating"]
        ]
      ]);
      onNext(value);
      expect(onNext).toHaveBeenCalledOnce();
      expect(onNext.calls[0].positionalArguments[0]).toEqual({
        'jsonGraph': {
          'titlesById': {
            1: {'name': 'Orange is the new Black', 'rating': 5}
          }
        }
      });
    });
  });
}
