import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/falcor_dart.dart';

main() {
  describe('Materialized Paths.', () {
    it('should validate routes that do not return all the paths asked for.',
        () async {
      var routes = [
        {
          'route': 'one[{integers:ids}]',
          'get': (aliasMap) {
            return {
              'path': ['one', 0],
              'value': $ref('two.be[956]')
            };
          }
        }
      ];
      var router = new Router(routes);
      var res = await router.get([
        [
          'one',
          [0, 1],
          'summary'
        ]
      ]);
      var count = 0;

      expect(res).toEqual({
        'jsonGraph': {
          'one': {
            0: $ref('two.be[956]'),
            1: {
              'summary': $atom(null)
            }
          },
          'two': {
            'be': {
              956: {
                'summary': $atom(null)
              }
            }
          }
        }
      });
      count++;

      expect(count).toEqual(1);
    });

    it('should validate when no route is matched', () async {
      var routes = [];
      var router = new Router(routes);
      var res = await router.get([
        [
          'one',
          [0, 1],
          'summary'
        ]
      ]);
      expect(res).toEqual({
        'jsonGraph': {
          'one': {
            0: {
              'summary': $atom(null)
            },
            1: {
              'summary': $atom(null)
            }
          }
        }
      });
    });
  });
}
