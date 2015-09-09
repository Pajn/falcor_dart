import 'package:falcor_dart/falcor_dart.dart';
import 'package:guinness2/guinness2.dart';
import '../../../data/routes.dart';
import '../../../testrunner.dart';
import '../../../data/expected.dart';

main() {
  describe('Ranges', () {
    it('should match integers for videos with int keys passed in.', () {
      var router = new Router(routes().Videos.Ranges.Summary((pathSet) {
        TestRunner.comparePath([
          'videos',
          [
            {'from': 1, 'to': 1}
          ],
          'summary'
        ], pathSet);
      }));
      var obs = router.get([
        ['videos', 1, 'summary']
      ]);

      TestRunner.run(obs, [expectedRoutes().Videos[1].summary]);
    });

    it('should match ranges for videos with array of ints passed in.', () {
      var router = new Router(routes().Videos.Ranges.Summary((pathSet) {
        TestRunner.comparePath([
          'videos',
          [
            {'from': 1, 'to': 2}
          ],
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
        expectedRoutes().Videos[1].summary,
        expectedRoutes().Videos[2].summary
      ]);
    });

    it('should match ranges for videos with array of ints passed in that are not adjacent.',
        () {
      var router = new Router(routes().Videos.Ranges.Summary((pathSet) {
        TestRunner.comparePath([
          'videos',
          [
            {'from': 0, 'to': 0},
            {'from': 2, 'to': 2}
          ],
          'summary'
        ], pathSet);
      }));
      var obs = router.get([
        [
          'videos',
          [0, 2],
          'summary'
        ]
      ]);

      TestRunner.run(obs, [
        expectedRoutes().Videos[0].summary,
        expectedRoutes().Videos[2].summary
      ]);
    });

    it('should match ranges with a range passed in.', () {
      var router = new Router(routes().Videos.Ranges.Summary((pathSet) {
        TestRunner.comparePath([
          'videos',
          [
            {'from': 0, 'to': 2}
          ],
          'summary'
        ], pathSet);
      }));
      var obs = router.get([
        [
          'videos',
          {'from': 0, 'to': 2},
          'summary'
        ]
      ]);

      TestRunner.run(obs, [
        expectedRoutes().Videos[0].summary,
        expectedRoutes().Videos[1].summary,
        expectedRoutes().Videos[2].summary
      ]);
    });

    it('should match ranges as last key.', () {
      var router = new Router(routes().Videos.State.Ranges((pathSet) {
        TestRunner.comparePath([
          'videos',
          'state',
          [
            {'from': 0, 'to': 0}
          ]
        ], pathSet);
      }));
      var obs = router.get([
        ['videos', 'state', 0]
      ]);

      TestRunner.run(obs, [expectedRoutes().Videos.state[0]]);
    });
  });
}
