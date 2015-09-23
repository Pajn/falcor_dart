library falcor_dart.multi_indexer_test;

import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/router.dart';

main() {
  describe('Multi-Indexer', () {
    it('should allow multiple string indexers to collapse into a single request in leaf position.',
        () async {
      var serviceCalls = 0;
      var router = new Router([
        route('test["one", "two", "three"]', get: (pathSet) {
          var keys = pathSet[1];
          serviceCalls++;

          expect(keys).toBeA(List);
          return keys.map((k) {
            return {
              'path': ['test', k],
              'value': k
            };
          });
        }),
      ]);

      var value = await router.get([
        [
          "test",
          ['one', 'two']
        ]
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'test': {'one': 'one', 'two': 'two'}
        }
      });
      expect(serviceCalls).toEqual(1);
    });

    it('should allow multiple string indexers to collapse into a single request in branch position.',
        () async {
      var serviceCalls = 0;
      var router = new Router([
        route('test["one", "two", "three"].summary', get: (pathSet) {
          var keys = pathSet[1];
          serviceCalls++;

          expect(keys).toBeA(List);
          return keys.map((k) {
            return {
              'path': ['test', k, 'summary'],
              'value': k
            };
          });
        }),
      ]);

      var value = await router.get([
        [
          'test',
          ['one', 'two'],
          'summary'
        ]
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'test': {
            'one': {'summary': 'one'},
            'two': {'summary': 'two'}
          }
        }
      });
      expect(serviceCalls).toEqual(1);
    });

    it('should allow multiple string indexers to collapse into a single request with named and unnamed routed tokens.',
        () async {
      var serviceCalls = 0;
      var router = new Router([
        route('test["one", "two", "three"][{ranges}][{integers:ids}]',
            get: (pathSet) {
          var keys = pathSet[1];
          serviceCalls++;

          expect(keys).toBeA(List);
          return keys.map((k) {
            return {
              'path': ['test', k, 0, 0],
              'value': k
            };
          });
        }),
      ]);

      var value = await router.get([
        [
          'test',
          ['one', 'two'],
          0,
          0
        ]
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'test': {
            'one': {
              0: {0: 'one'}
            },
            'two': {
              0: {0: 'two'}
            }
          }
        }
      });
      expect(serviceCalls).toEqual(1);
    });

    it('should allow single string indexers to be coerced into an array when handed to route.',
        () async {
      var serviceCalls = 0;
      var router = new Router([
        route('test["one", "two", "three"]', get: (pathSet) {
          var keys = pathSet[1];
          serviceCalls++;

          expect(keys).toBeA(List);
          return keys.map((k) {
            return {
              'path': ['test', k],
              'value': k
            };
          });
        }),
      ]);

      var value = await router.get([
        [
          "test",
          ['one']
        ]
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'test': {'one': 'one'}
        }
      });
      expect(serviceCalls).toEqual(1);
    });

    it('should fire multiple service calls', () async {
      var serviceCalls = 0;
      var router = new Router([
        route('test["one", "two"]["three", "four"]', get: (pathSet) {
          var part1 = pathSet[1];
          var part2 = pathSet[2];
          serviceCalls++;

          expect(part1).toBeA(List);
          expect(part2).toBeA(List);
          var res = [];
          part1.forEach((p1) {
            part2.forEach((p2) {
              res.add({
                'path': ['test', p1, p2],
                'value': p1 + p2
              });
            });
          });

          return res;
        }),
      ]);

      var value = await router.get([
        ["test", 'one', 'three'],
        ["test", 'two', 'four']
      ]);

      expect(value).toEqual({
        'jsonGraph': {
          'test': {
            'one': {'three': 'onethree'},
            'two': {'four': 'twofour'}
          }
        }
      });
      expect(serviceCalls).toEqual(2);
    });
  });
}
