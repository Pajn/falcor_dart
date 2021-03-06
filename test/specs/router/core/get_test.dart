import 'package:guinness2/guinness2.dart';

import 'package:falcor_dart/router.dart';
import 'package:falcor_dart/src/types/sentinels.dart';

import '../../../data/routes.dart';
import '../../../data/expected.dart';
import 'package:falcor_dart/src/path_set.dart';

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
        route('videos.falsey',
            get: (_) => {
                  'jsonGraph': {
                    'videos': {'falsey': null}
                  },
                  'paths': [
                    ['videos', 'falsey']
                  ]
                }),
      ]);

      var value = await router.get([
        ['videos', 'falsey']
      ]);

      expect(value).toEqual({
        'jsonGraph': {
          'videos': {'falsey': null}
        }
      });
    });

    it('should not return empty atoms for a null value atom in jsonGraph',
        () async {
      var router = new Router([
        route('videos.falsey',
            get: (_) => {
                  'jsonGraph': {
                    'videos': {'falsey': $atom(null)}
                  },
                  'paths': [
                    ['videos', 'falsey']
                  ]
                }),
      ]);

      var value = await router.get([
        ['videos', 'falsey']
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'videos': {'falsey': $atom(null)}
        }
      });
    });

    it('should not return empty atoms for a zero value in jsonGraph', () async {
      var router = new Router([
        route('videos.falsey',
            get: (_) => {
                  'jsonGraph': {
                    'videos': {'falsey': 0}
                  },
                  'paths': [
                    ['videos', 'falsey']
                  ]
                }),
      ]);

      var value = await router.get([
        ['videos', 'falsey']
      ]);

      expect(value).toEqual({
        'jsonGraph': {
          'videos': {'falsey': 0}
        }
      });
    });

    it('should not return empty atoms for a zero value atom in jsonGraph',
        () async {
      var router = new Router([
        route('videos.falsey',
            get: (_) => {
                  'jsonGraph': {
                    'videos': {'falsey': $atom(0)}
                  },
                  'paths': [
                    ['videos', 'falsey']
                  ]
                }),
      ]);

      var value = await router.get([
        ['videos', 'falsey']
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'videos': {'falsey': $atom(0)}
        }
      });
    });

    it('should not return empty atoms for a zero path value', () async {
      var router = new Router([
        route('videos.falsey',
            get: (_) => {
                  'value': 0,
                  'path': ['videos', 'falsey']
                }),
      ]);

      var value = await router.get([
        ['videos', 'falsey']
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'videos': {'falsey': 0}
        }
      });
    });

    it('should not return empty atoms for a null path value', () async {
      var router = new Router([
        route('videos.falsey',
            get: (_) => {
                  'value': null,
                  'path': ['videos', 'falsey']
                }),
      ]);

      var value = await router.get([
        ['videos', 'falsey']
      ]);
      expect(value).toEqual({
        'jsonGraph': {
          'videos': {'falsey': null}
        }
      });
    });

    it('should not return empty atoms for a false path value', () async {
      var router = new Router([
        route('videos.falsey',
            get: (_) => {
                  'value': false,
                  'path': ['videos', 'falsey']
                }),
      ]);

      var value = await router.get([
        ['videos', 'falsey']
      ]);

      expect(value).toEqual({
        'jsonGraph': {
          'videos': {'falsey': false}
        }
      });
    });

    it('should not return empty atoms for a empty string path value', () async {
      var router = new Router([
        route('videos.falsey',
            get: (_) => {
                  'value': '',
                  'path': ['videos', 'falsey']
                }),
      ]);

      var value = await router.get([
        ['videos', 'falsey']
      ]);

      expect(value).toEqual({
        'jsonGraph': {
          'videos': {'falsey': ''}
        }
      });
    });

    it('should validate that optimizedPathSets strips out already found data.',
        () async {
      var serviceCalls = 0;
      var routes = [
        route('lists[{keys:ids}]',
            get: (pathSet) => pathSet['ids'].map((id) {
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
                })),
        route('two.be[{integers:ids}].summary',
            get: (pathSet) => pathSet['ids'].map((id) {
                  serviceCalls++;
                  return {
                    'path': ['two', 'be', id, 'summary'],
                    'value': 'hello world'
                  };
                })),
      ];
      var router = new Router(routes);
      var value = await router.get([
        [
          'lists',
          [0, 1],
          'summary'
        ]
      ]);

      expect(value).toEqual({
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
        var expected = new PathSet();
        expected.addAll([
          'videos',
          [123],
          'title'
        ]);
        expected['ids'] = expected[1];
        expect(alias).toEqual(expected);
        title++;
      }, onRating: (alias) {
        var expected = new PathSet();
        expected.addAll([
          'videos',
          [123],
          'rating'
        ]);
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
            123: {'title': 'title 123', 'rating': 'rating 123'}
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
            'abc': {0: $ref('videos[0]')}
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
            1: {
              'ProductsList': {
                0: $ref(['ProductsById', 'CSC1471105X'], size: 52),
                1: $ref(['ProductsById', 'HON4033T'], size: 52)
              }
            }
          }
        }
      };
      var router = new Router([
        route('ProductsById[{keys}][{keys}]',
            get: (_) => throw new Exception('reference was followed in error')),
        route('ProffersById[{integers}].ProductsList[{ranges}]',
            get: (_) => routeResponse),
      ]);
      var obs = await router.get([
        [
          'ProffersById',
          1,
          'ProductsList',
          {'from': 0, 'to': 1}
        ]
      ]);
      expect(obs).toEqual(routeResponse);
    });

    it('should tolerate routes which return an empty observable', () async {
      var router =
          new Router([route('videos[{integers:ids}].title', get: (_) => []),]);
      var obs = await router.get([
        ['videos', 1, 'title']
      ]);
      expect(obs).toEqual({
        'jsonGraph': {
          'videos': {
            1: {'title': $atom(null)}
          }
        }
      });
    });
  });

  it('should throw helpful error if null is returned.', () async {
    var router = new Router([route('null', get: (_) => null)]);

    try {
      await router.get([
        ['null']
      ]);
      throw 'Should have thrown a NullReturnedError';
    } on NullReturnedError catch (_) {}
  });

  it('should not differ between numbers and strings', () async {
    var router = getPrecedenceRouter();
    var obs = await router.get([
      ['videos', '1', 'title']
    ]);
    expect(obs).toEqual({
      'jsonGraph': {
        'videos': {
          1: {'title': 'title 1'}
        }
      }
    });
  });
}

getPrecedenceRouter({onTitle(PathSet pathSet), onRating(PathSet pathSet)}) {
  return new Router([
    route('videos[{integers:ids}].title', get: (pathSet) {
      var ids = pathSet['ids'];
      if (onTitle != null) {
        onTitle(pathSet);
      }
      return ids.map((id) {
        return {
          'path': ['videos', id, 'title'],
          'value': 'title $id',
        };
      });
    }),
    route('videos[{integers:ids}].rating', get: (pathSet) {
      var ids = pathSet['ids'];
      if (onRating != null) {
        onRating(pathSet);
      }
      return ids.map((id) {
        return {
          'path': ['videos', id, 'rating'],
          'value': 'rating $id',
        };
      });
    }),
    route('lists[{keys:ids}][{integers:indices}]',
        get: (pathSet) => pathSet['ids'].expand((id) {
              return pathSet['indices'].map((idx) {
                return {'id': id, 'idx': idx};
              });
            }).map((data) {
              return {
                'path': ['lists', data['id'], data['idx']],
                'value': $ref(['videos', data['idx']])
              };
            })),
  ]);
}
