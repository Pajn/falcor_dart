import 'package:guinness2/guinness2.dart';

import 'package:dart_ext/collection_ext.dart' as extMerge;

import 'package:falcor_dart/falcor_dart.dart';
import 'package:falcor_dart/src/types/sentinels.dart';
import 'package:falcor_dart/src/cache/jsong_merge.dart';

main() {
/**
 * normally i don't test internals but i think the merges
 * warrent internal testing.  The reason being is that the
 * merges are core to the product.  If i don't, i will have to
 * figure out where bugs are without much clarity into where they
 * are.
 */
  describe('JSONG - Merge', () {
    it('should write a simple path to the cache.', () async {
      var jsong = {
        'jsonGraph': {
          'there': {'is': $atom('a value')}
        },
        'paths': [
          ['there', 'is']
        ]
      };

      var out = mergeTest(jsong);

      expect(out).toEqual({
        'values': [
          {
            'path': ['there', 'is'],
            'value': $atom('a value')
          }
        ],
        'references': []
      });
    });

    it('should write a falsey number to the cache.', () async {
      var jsong = {
        'jsonGraph': {
          'there': {'is': 0}
        },
        'paths': [
          ['there', 'is']
        ]
      };

      var out = mergeTest(jsong);
      expect(out).toEqual({
        'values': [
          {
            'path': ['there', 'is'],
            'value': 0
          }
        ],
        'references': []
      });
    });

    it('should write a falsey string to the cache.', () async {
      var jsong = {
        'jsonGraph': {
          'there': {'is': ''}
        },
        'paths': [
          ['there', 'is']
        ]
      };

      var out = mergeTest(jsong);
      expect(out).toEqual({
        'values': [
          {
            'path': ['there', 'is'],
            'value': ''
          }
        ],
        'references': []
      });
    });

    it('should write a false boolean to the cache.', () async {
      var jsong = {
        'jsonGraph': {
          'there': {'is': false}
        },
        'paths': [
          ['there', 'is']
        ]
      };

      var out = mergeTest(jsong);
      expect(out).toEqual({
        'values': [
          {
            'path': ['there', 'is'],
            'value': false
          }
        ],
        'references': []
      });
    });

    it('should write a null to the cache.', () async {
      var jsong = {
        'jsonGraph': {
          'there': {'is': null}
        },
        'paths': [
          ['there', 'is']
        ]
      };

      var out = mergeTest(jsong);
      expect(out).toEqual({
        'values': [
          {
            'path': ['there', 'is'],
            'value': null
          }
        ],
        'references': []
      });
    });

    it('should write a path with a reference to a value.', () async {
      var jsong = {
        'jsonGraph': {
          'there': {'is': $ref('a.value')},
          'a': {'value': $atom('was here')}
        },
        'paths': [
          ['there', 'is']
        ]
      };
      mergeTest(jsong);
    });

    it('should write a path with a reference to a branch.', () async {
      var jsong = {
        'jsonGraph': {
          'there': {'is': $ref('a')},
          'a': {'value': $atom('was here')}
        },
        'paths': [
          ['there', 'is', 'value']
        ]
      };

      mergeTest(jsong);
    });

    it('should write a path with a reference to a reference.', () async {
      var jsong = {
        'jsonGraph': {
          'there': {'is': $ref('a')},
          'a': $ref('value'),
          'value': $atom('was here')
        },
        'paths': [
          ['there', 'is']
        ]
      };

      mergeTest(jsong);
    });

    iit('should get the set refs.', () async {
      var jsong = {
        'jsonGraph': {
          'there': {'is': $ref('a')}
        },
        'paths': [
          ['there', 'is']
        ]
      };
      var cache = {};
      var out = jsongMerge(cache, jsong);
      expect(out).toEqual({
        'values': [],
        'references': [
          {
            'path': ['there', 'is'],
            'value': ['a']
          }
        ]
      });
    });

    iit('should get the set values and refs.', () async {
      var jsong = {
        'jsonGraph': {
          'there': {'is': $ref('a'), 'was': $ref('b')},
          'a': {'value': 5}
        },
        'paths': [
          ['there', 'is', 'value'],
          ['there', 'was']
        ]
      };
      var cache = {};
      var out = jsongMerge(cache, jsong);
      expect(out).toEqual({
        'values': [
          {
            'path': ['there', 'is', 'value'],
            'value': 5
          }
        ],
        'references': [
          {
            'path': ['there', 'was'],
            'value': ['b']
          }
        ]
      });
    });
  });
}

mergeTest(jsong) {
  var cache = {
    'there': {'was': $atom('a value')}
  };

  var expected = extMerge.merge(cache, jsong['jsonGraph']);

  print('TEST');
  print(cache);

  var out = jsongMerge(cache, jsong);
  expect(cache).toEqual(expected);

  return out;
}
