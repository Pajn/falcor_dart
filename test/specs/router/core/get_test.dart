import 'package:guinness2/guinness2.dart';

import 'package:falcor_dart/falcor_dart.dart';
import 'package:falcor_dart/src/types/sentinels.dart';

import '../../../data/routes.dart';
import '../../../data/expected.dart';

main() {
  describe('Get', () {
    it('should execute a simple route matching.', () async {
      var router = new Router(routes()['Videos']['Summary']());
      var obs = await router.get([
        ['videos', 'summary']
      ]);

      expect(obs).toEqual(expectedRoutes()['Videos']['Summary']);
    });

    it('should not return empty atoms for a null value in jsonGraph', () async {
      var router = new Router([
        {
          'route': 'videos.falsey',
          'get': (path) {
            return {
              'jsonGraph': {
                'videos': {'falsey': null}
              },
              'paths': [
                ['videos', 'falsey']
              ]
            };
          }
        }
      ]);

      var onNext = new SpyFunction('onNext');

      var value = await router.get([
        ['videos', 'falsey']
      ]);

      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.calls[0].positionalArguments[0]).toEqual({
        'jsonGraph': {
          'videos': {'falsey': null}
        }
      });
    });

    it('should not return empty atoms for a null value atom in jsonGraph',
        () async {
      var router = new Router([
        {
          'route': 'videos.falsey',
          'get': (path) {
            return {
              'jsonGraph': {
                'videos': {'falsey': $atom(null)}
              },
              'paths': [
                ['videos', 'falsey']
              ]
            };
          }
        }
      ]);

      var onNext = new SpyFunction('onNext');

      var value = await router.get([
        ['videos', 'falsey']
      ]);
      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.calls[0].positionalArguments[0]).toEqual({
        'jsonGraph': {
          'videos': {'falsey': $atom(null)}
        }
      });
    });

    it('should not return empty atoms for a zero value in jsonGraph', () async {
      var router = new Router([
        {
          'route': 'videos.falsey',
          'get': (path) {
            return {
              'jsonGraph': {
                'videos': {'falsey': 0}
              },
              'paths': [
                ['videos', 'falsey']
              ]
            };
          }
        }
      ]);

      var onNext = new SpyFunction('onNext');

      var value = router.get([
        ['videos', 'falsey']
      ]);

      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.getCall(0).args[0]).toEqual({
        'jsonGraph': {
          'videos': {'falsey': 0}
        }
      });
    });

    it('should not return empty atoms for a zero value atom in jsonGraph',
        () async {
      var router = new Router([
        {
          'route': 'videos.falsey',
          'get': (path) {
            return {
              'jsonGraph': {
                'videos': {'falsey': $atom(0)}
              },
              'paths': [
                ['videos', 'falsey']
              ]
            };
          }
        }
      ]);

      var onNext = new SpyFunction('onNext');

      var value = await router.get([
        ['videos', 'falsey']
      ]);
      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.getCall(0).args[0]).toEqual({
        'jsonGraph': {
          'videos': {'falsey': $atom(0)}
        }
      });
    });

    it('should not return empty atoms for a zero path value', () async {
      var router = new Router([
        {
          'route': 'videos.falsey',
          'get': (path) {
            return {
              'value': 0,
              'path': ['videos', 'falsey']
            };
          }
        }
      ]);

      var onNext = new SpyFunction('onNext');

      var value = await router.get([
        ['videos', 'falsey']
      ]);
      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.getCall(0).args[0]).toEqual({
        'jsonGraph': {
          'videos': {'falsey': 0}
        }
      });
    });

    it('should not return empty atoms for a null path value', () async {
      var router = new Router([
        {
          'route': 'videos.falsey',
          'get': (path) {
            return {
              'value': null,
              'path': ['videos', 'falsey']
            };
          }
        }
      ]);

      var onNext = new SpyFunction('onNext');

      var value = await router.get([
        ['videos', 'falsey']
      ]);
      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.getCall(0).args[0]).toEqual({
        'jsonGraph': {
          'videos': {'falsey': null}
        }
      });
    });

    it('should not return empty atoms for a false path value', () async {
      var router = new Router([
        {
          'route': 'videos.falsey',
          'get': (path) {
            return {
              'value': false,
              'path': ['videos', 'falsey']
            };
          }
        }
      ]);

      var onNext = new SpyFunction('onNext');

      var value = await router.get([
        ['videos', 'falsey']
      ]);
      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.getCall(0).args[0]).toEqual({
        'jsonGraph': {
          'videos': {'falsey': false}
        }
      });
    });

    it('should not return empty atoms for a empty string path value', () async {
      var router = new Router([
        {
          'route': 'videos.falsey',
          'get': (path) {
            return {
              'value': '',
              'path': ['videos', 'falsey']
            };
          }
        }
      ]);

      var onNext = new SpyFunction('onNext');

      var value = await router.get([
        ['videos', 'falsey']
      ]);
      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.getCall(0).args[0]).toEqual({
        'jsonGraph': {
          'videos': {'falsey': ''}
        }
      });
    });

    it('should validate that optimizedPathSets strips out already found data.',
        () async {
      //    this.timeout(10000);
      var serviceCalls = 0;
      var onNext = new SpyFunction('onNext');
      var routes = [
        {
          'route': 'lists[{keys:ids}]',
          'get': (aliasMap) {
            return aliasMap.ids.map((id) {
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
            })
                .

                // Note: this causes the batching to work.
                toArray();
          }
        },
        {
          'route': 'two.be[{integers:ids}].summary',
          'get': (aliasMap) {
            return aliasMap.ids.map((id) {
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
      var value = await router.get([
        [
          'lists',
          [0, 1],
          'summary'
        ]
      ]);
      expect(onNext.calledOnce).toHaveBeenCalledOnce();
      expect(onNext.getCall(0).args[0]).toEqual({
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

    it('should do precedence stripping.', () async {
      var title = 0;
      var rating = 0;
      var called = 0;
      var router = getPrecedenceRouter(onTitle: (alias) {
        var expected = [
          'videos',
          [123],
          'title'
        ];
        expected['ids'] = expected[1];
        expect(alias).toEqual(expected);
        title++;
      }, onRating: (alias) {
        var expected = [
          'videos',
          [123],
          'rating'
        ];
        expected['ids'] = expected[1];
        expect(alias).toEqual(expected);
        rating++;
      });

      var value = await router.get([
        [
          'videos',
          123,
          ['title', 'rating']
        ]
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'videos': {
            '123': {'title': 'title 123', 'rating': 'rating 123'}
          }
        }
      });
      called++;

      expect(title).toEqual(1);
      expect(rating).toEqual(1);
      expect(called).toEqual(1);
    });

    it('should grab a reference.', () async {
      var called = 0;
      var router = getPrecedenceRouter();
      var value = await router.get([
        ['lists', 'abc', 0]
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'lists': {
            'abc': {'0': $ref('videos[0]')}
          }
        }
      });
      called++;
      expect(called).toEqual(1);
    });

    it('should not follow references if no keys specified after path to reference',
        () async {
      var routeResponse = {
        'jsonGraph': {
          'ProffersById': {
            '1': {
              'ProductsList': {
                '0': {
                  r'$size': 52,
                  r'$type': 'ref',
                  'value': ['ProductsById', 'CSC1471105X']
                },
                '1': {
                  r'$size': 52,
                  r'$type': 'ref',
                  'value': ['ProductsById', 'HON4033T']
                }
              }
            }
          }
        }
      };
      var router = new Router([
        {
          'route': 'ProductsById[{keys}][{keys}]',
          'get': (pathSet) {
            throw new Exception('reference was followed in error');
          }
        },
        {
          'route': 'ProffersById[{integers}].ProductsList[{ranges}]',
          'get': (pathSet) {
            return routeResponse;
          }
        }
      ]);
      var obs = await router.get([
        [
          'ProffersById',
          1,
          'ProductsList',
          {'from': 0, 'to': 1}
        ]
      ]);
      var called = false;
      expect(obs).toEqual(routeResponse);
    });

    it('should tolerate routes which return an empty observable', () async {
      var router = new Router([
        {
          'route': 'videos[{integers:ids}].title',
          'get': (alias) {
            return [];
          }
        }
      ]);
      var obs = await router.get([
        ['videos', 1, 'title']
      ]);
      var called = false;
      expect(obs).toEqual({
        'jsonGraph': {
          'videos': {
            1: {
              'title': {r'$type': 'atom'}
            }
          }
        }
      });
    });
  });
}

getPrecedenceRouter({onTitle, onRating}) {
  return new Router([
    {
      'route': 'videos[{integers:ids}].title',
      'get': (alias) {
        var ids = alias.ids;
        onTitle && onTitle(alias);
        return ids.map((id) {
          return {
            'path': ['videos', id, 'title'],
            'value': 'title ' + id
          };
        });
      }
    },
    {
      'route': 'videos[{integers:ids}].rating',
      'get': (alias) {
        var ids = alias.ids;
        onRating && onRating(alias);
        return ids.map((id) {
          return {
            'path': ['videos', id, 'rating'],
            'value': 'rating ' + id
          };
        });
      }
    },
    {
      'route': 'videos[{integers:ids}].rating',
      'get': (alias) {
        var ids = alias.ids;
        onRating && onRating(alias);
        return ids.map((id) {
          return {
            'path': ['videos', id, 'rating'],
            'value': 'rating ' + id
          };
        });
      }
    },
    {
      'route': 'lists[{keys:ids}][{integers:indices}]',
      'get': (alias) {
        return alias.ids.flatMap((id) {
          return alias.indices.map((idx) {
            return {'id': id, 'idx': idx};
          });
        }).map((data) {
          return {
            'path': ['lists', data.id, data.idx],
            'value': $ref(['videos', data.idx])
          };
        });
      }
    }
  ]);
}
