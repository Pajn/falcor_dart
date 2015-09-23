import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/router.dart';
import 'package:falcor_dart/src/cache/path_value_merge.dart';

main() {
  describe('PathValue - Merge', () {
    it('should write a simple path to the cache with pathValue.', () {
      var expected = {
        'there': {'was': $atom('a value'), 'is': $atom('a value')}
      };

      var cache = {
        'there': {'was': $atom('a value')}
      };

      var pV = {
        'path': ['there', 'is'],
        'value': $atom('a value')
      };

      pathValueMerge(cache, pV);
      expect(cache).toEqual(expected);
    });
    it('should write a complex leaf path to the cache with pathValue.', () {
      var expected = {
        'there': {'was': $atom('a value'), 'is': $atom('a value')}
      };

      var cache = {};

      var pV = {
        'path': [
          'there',
          ['is', 'was']
        ],
        'value': $atom('a value')
      };

      pathValueMerge(cache, pV);
      expect(cache).toEqual(expected);
    });
    it('should write a complex branch path to the cache with pathValue.', () {
      var expected = {
        'there': {'be': $atom('a value')},
        'could': {'be': $atom('a value')}
      };

      var cache = {};

      var pV = {
        'path': [
          ['could', 'there'],
          'be'
        ],
        'value': $atom('a value')
      };

      pathValueMerge(cache, pV);
      expect(cache).toEqual(expected);
    });
    it('should get the set refs.', () {
      var pV = {
        'path': ['there', 'is'],
        'value': $ref('a')
      };
      var cache = {};
      var out = pathValueMerge(cache, pV);
      expect(out).toEqual({
        'references': [
          {
            'path': ['there', 'is'],
            'value': ['a']
          }
        ],
        'values': [],
        'invalidations': []
      });
    });

    it('should get the set values.', () {
      var cache = {
        'jsonGraph': {
          'there': {'is': $ref('a')}
        }
      };
      var pVs = {
        'path': ['there', 'was', 'value'],
        'value': 5
      };
      var out = pathValueMerge(cache, pVs);
      expect(out).toEqual({
        'values': [
          {
            'path': ['there', 'was', 'value'],
            'value': 5
          }
        ],
        'references': [],
        'invalidations': []
      });
    });

    it('should get a pathSet of values.', () {
      var cache = {
        'jsonGraph': {
          'there': {'is': $ref('a')}
        }
      };
      var pVs = {
        'path': [
          'there',
          'was',
          ['value', 'v2', 'v3']
        ],
        'value': 5
      };
      var out = pathValueMerge(cache['jsonGraph'], pVs);
      expect(out).toEqual({
        'values': [
          {
            'path': [
              'there',
              'was',
              ['value', 'v2', 'v3']
            ],
            'value': 5
          }
        ],
        'references': [],
        'invalidations': []
      });
      expect(cache).toEqual({
        'jsonGraph': {
          'there': {
            'is': $ref('a'),
            'was': {'value': 5, 'v2': 5, 'v3': 5}
          }
        }
      });
    });
  });
}
