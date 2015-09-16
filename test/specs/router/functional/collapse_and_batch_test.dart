import 'package:guinness2/guinness2.dart';

import 'package:falcor_dart/falcor_dart.dart';
import 'package:falcor_dart/src/types/sentinels.dart';
import '../../../data/routes.dart';
import 'dart:async';

main() {
  describe('Collapse and Batch', () {
    it('should ensure that collapse is being ran.', () async {
      var videos = routes()['Videos']['Integers']['Summary']((path) {
        expect(path).toEqual([
          'videos',
          [0, 1],
          'summary'
        ]);
      });
      var genreLists = routes()['Genrelists']['Integers']((incomingPaths) {
        expect(incomingPaths).toEqual([
          'genreLists',
          [new Range(0, 1)]
        ]);
      });
      var router = new Router(videos..addAll(genreLists));
      var res = await router.get([
        [
          'genreLists',
          [0, 1],
          'summary'
        ]
      ]);

      expect(res).toEqual({
        'jsonGraph': {
          'genreLists': {0: $ref('videos[0]'), 1: $ref('videos[1]')},
          'videos': {
            0: {
              'summary': $atom({'title': 'Some Movie 0'})
            },
            1: {
              'summary': $atom({'title': 'Some Movie 1'})
            }
          }
        }
      });
    });

    //todo(Rasmus): Fix this test
    it('should validate that paths are ran in parallel, not sequentially.',
        () async {
      // Not sure about this so just commented out for now...
      // this.timeout(10000);
      var calls;
      var serviceCalls = 0;
      var testedTwo = false;
      called(res) {
        if (!calls) {
          calls = [];
        }
        calls.add(res);
        serviceCalls++;
        // Not sure about this so just commented out for now...
        // process.nextTick(() {
        // if (calls.length == 0) {
        // return;
        // }

        expect(serviceCalls).toEqual(2);
        expect(calls.length).toEqual(2);
        calls.length = 0;
        testedTwo = true;
      };

      var routes = [
        {
          'route': 'one[{integers:ids}]',
          'get': (aliasMap) {
            return aliasMap['ids'].map((id) {
              if (id == 0) {
                return {
                  'path': ['one', id],
                  'value': $ref('two.be[956]')
                };
              }
              return {
                'path': ['one', id],
                'value': $ref('three.four[111]')
              };
            });
          }
        },
        {
          'route': 'two.be[{integers:ids}].summary',
          'get': (aliasMap) async {
            called(1);
            await new Future.delayed(new Duration(milliseconds: 500));
            return aliasMap['ids']
                .map((id) {
              return {
                'path': ['two', 'be', id, 'summary'],
                'value': 'hello world'
              };
            });
          }
        },
        {
          'route': 'three.four[{integers:ids}].summary',
          'get': (aliasMap) async{
            // Not sure about this so just commented out for now...
            called(2);
            await new Future.delayed(new Duration(milliseconds: 500));
            return aliasMap['ids']
                .map((id) {
              return {
                'path': ['three', 'four', id, 'summary'],
                'value': 'hello saturn'
              };
            });
          }
        }
      ];
      var router2 = new Router(routes);
      var obs = await router2.get([
        [
          'one',
          [0, 1],
          'summary'
        ]
      ]);
      var time = new DateTime.now().millisecondsSinceEpoch;
      var nextTime = new DateTime.now().millisecondsSinceEpoch;
      expect(nextTime - time >= 4000).toEqual(false);

      expect(testedTwo).toEqual(true);
    });

    it('should validate that optimizedPathSets strips out already found data and collapse makes one request.',
        () async {
      var serviceCalls = 0;
      var routes = [
        {
          'route': 'lists[{keys:ids}]',
          'get': (aliasMap) {
            return aliasMap['ids'].map((id) {
              if (id == 0) {
                return {
                  'path': ['lists', id],
                  'value': $ref('two.be[956]')
                };
              }
              return {
                'path': ['lists', id],
                'value': $ref('lists[0]')
              };
            });
          }
        },
        {
          'route': 'two.be[{integers:ids}].summary',
          'get': (aliasMap) {
            return aliasMap['ids'].map((id) {
              serviceCalls++;
              return {
                'path': ['two', 'be', id, 'summary'],
                'value': 'hello world'
              };
            });
          }
        }
      ];
      var router = new Router(routes);
      var res = await router.get([
        [
          'lists',
          [0, 1],
          'summary'
        ]
      ]);
      expect(res).toEqual({
        'jsonGraph': {
          'lists': {0: $ref('two.be[956]'), 1: $ref('lists[0]')},
          'two': {
            'be': {
              956: {'summary': 'hello world'}
            }
          }
        }
      });
      expect(serviceCalls).toEqual(1);
    });

    //todo(Rasmus): How do this translate to a world without Rx?
    it('should validate batching/collapsing makes two request since its onNextd without toArray().',
        () async {
      var serviceCalls = 0;
      var routes = [
        {
          'route': 'lists[{keys:ids}]',
          'get': (aliasMap) {
            return Future.wait(aliasMap['ids'].map((id) async {
              if (id == 0) {
                return {
                  'path': ['lists', id],
                  'value': $ref('two.be[956]')
                };
              }
              await new Future.delayed(new Duration(milliseconds: 50));
              return {
                'path': ['lists', id],
                'value': $ref('lists[0]')
              };
            }));
          }
        },
        {
          'route': 'two.be[{integers:ids}].summary',
          'get': (aliasMap) {
            print(aliasMap);
            return aliasMap['ids'].map((id) {
              serviceCalls++;
              return {
                'path': ['two', 'be', id, 'summary'],
                'value': 'hello world'
              };
            });
          }
        }
      ];
      var router = new Router(routes);
      var res = await router.get([
        [
          'lists',
          [0, 1],
          'summary'
        ]
      ]);
      expect(res).toEqual({
        'jsonGraph': {
          'lists': {0: $ref('two.be[956]'), 1: $ref('lists[0]')},
          'two': {
            'be': {
              956: {'summary': 'hello world'}
            }
          }
        }
      });
      expect(serviceCalls).toEqual(2);
    });

    it('should validate that a Promise that emits an array gets properly batched.',
        () async {
      var serviceCalls = 0;
      var routes = [
        {
          'route': 'promise[{integers:ids}]',
          'get': (aliasMap) {
            return new Future.sync(() {
              var pVs = aliasMap['ids'].map((id) {
                return {
                  'path': ['promise', id],
                  'value': $ref(['two', 'be', id, 'summary'])
                };
              });

              return pVs;
            });
          }
        },
        {
          'route': 'two.be[{integers:ids}].summary',
          'get': (aliasMap) {
            serviceCalls++;
            return aliasMap['ids'].map((id) {
              return {
                'path': ['two', 'be', id, 'summary'],
                'value': 'hello promise'
              };
            });
          }
        }
      ];
      var router = new Router(routes);
      await router.get([
        [
          'promise',
          [0, 1],
          'summary'
        ]
      ]);

      expect(serviceCalls).toEqual(1);
    });
  });
}
