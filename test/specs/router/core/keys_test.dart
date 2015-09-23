import 'package:guinness2/guinness2.dart';

import 'package:falcor_dart/router.dart';

import '../../../data/routes.dart';
import '../../../testrunner.dart';
import '../../../data/expected.dart';

main() {
  describe('Keys', () {
    it('should match integers for videos with int keys passed in.', () async {
      var router = new Router(routes()['Videos']['Keys']['Summary']((pathSet) {
        TestRunner.comparePath([
          'videos',
          [1],
          'summary'
        ], pathSet);
      }));
      var called = false;
      var value = await router.get([
        ['videos', 1, 'summary']
      ]);
      expect(value).toEqual(expectedRoutes()['Videos'][1]['summary']);
    });

    it('should match specific key with keys.', () async {
      var router = new Router(routes()['Videos']['Keys']['Summary']((pathSet) {
        TestRunner.comparePath([
          'videos',
          ['someKey'],
          'summary'
        ], pathSet);
      }));
      var called = false;
      var value = await router.get([
        ['videos', 'someKey', 'summary']
      ]);

      expect(value).toEqual(expectedRoutes()['Videos']['someKey']['summary']);
    });

    it('should match array of keys.', () async {
      var router = new Router(routes()['Videos']['Keys']['Summary']((pathSet) {
        TestRunner.comparePath([
          'videos',
          [1, 'someKey'],
          'summary'
        ], pathSet);
      }));
      var obs = await router.get([
        [
          'videos',
          [1, 'someKey'],
          'summary'
        ]
      ]);

      TestRunner.run(obs, [
        expectedRoutes()['Videos'][1]['summary'],
        expectedRoutes()['Videos']['someKey']['summary']
      ]);
    });

    it('should match range.', () {
      var router = new Router(routes()['Videos']['Keys']['Summary']((pathSet) {
        TestRunner.comparePath([
          'videos',
          [0, 1, 2],
          'summary'
        ], pathSet);
      }));
      var obs = router.get([
        [
          'videos',
          {'to': 2},
          'summary'
        ]
      ]);

      TestRunner.run(obs, [
        expectedRoutes()['Videos'][0]['summary'],
        expectedRoutes()['Videos'][1]['summary'],
        expectedRoutes()['Videos'][2]['summary']
      ]);
    });

    it('should match keys as last key.', () {
      var router = new Router(routes()['Videos']['State']['Keys']((pathSet) {
        TestRunner.comparePath([
          'videos',
          'state',
          ['specificKey']
        ], pathSet);
      }));
      var obs = router.get([
        ['videos', 'state', 'specificKey']
      ]);

      TestRunner.run(obs, [expectedRoutes()['Videos']['state']['specificKey']]);
    });
  });
}
