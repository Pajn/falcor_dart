import 'package:guinness2/guinness2.dart';

import 'package:falcor_dart/falcor_dart.dart';
import 'package:falcor_dart/src/types/sentinels.dart';
import 'package:falcor_dart/src/cache/jsong_merge.dart';
import 'package:falcor_dart/src/cache/optimize_path_set.dart';

main() {
  /**
   * normally i don't test internals but i think the merges
   * warrent internal testing.  The reason being is that the
   * merges are core to the product.  If i don't, i will have to
   * figure out where bugs are without much clarity into where they
   * are.
   */
  describe('optimizePathSets', () {
    it('should optimize simple path.', () async {
      var cache = getCache();
      var paths = [
        ['videosList', 3, 'summary']
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [
        ['videos', 956, 'summary']
      ];
      expect(out).toEqual(expected);
    });

    it('should optimize a complex path.', () async {
      var cache = getCache();
      var paths = [
        [
          'videosList',
          [0, 3],
          'summary'
        ]
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [
        ['videosList', 0, 'summary'],
        ['videos', 956, 'summary']
      ];
      expect(out).toEqual(expected);
    });

    it('should remove found paths', () async {
      var cache = getCache();
      var paths = [
        [
          'videosList',
          [0, 3, 5],
          'summary'
        ]
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [
        ['videosList', 0, 'summary'],
        ['videos', 956, 'summary']
      ];
      expect(out).toEqual(expected);
    });

    it('should follow double references.', () async {
      var cache = getCache();
      var paths = [
        ['videosList', 'double', 'summary']
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [
        ['videos', 956, 'summary']
      ];
      expect(out).toEqual(expected);
    });

    it('should short circuit on ref.', () async {
      var cache = getCache();
      var paths = [
        ['videosList', 'short', 'summary']
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [];
      expect(out).toEqual(expected);
    });

    it('should short circuit on primitive string values', () async {
      var cache = getCache();
      var paths = [
        ['videos', 6, 'summary']
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [];
      expect(out).toEqual(expected);
    });

    it('should short circuit on primitive number values', () async {
      var cache = getCache();
      var paths = [
        ['videos', 7, 'summary']
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [];
      expect(out).toEqual(expected);
    });

    it('should short circuit on primitive boolean values', () async {
      var cache = getCache();
      var paths = [
        ['videos', 8, 'summary']
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [];
      expect(out).toEqual(expected);
    });

    it('should short circuit on primitive null value', () async {
      var cache = getCache();
      var paths = [
        ['videos', 9, 'summary']
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [];
      expect(out).toEqual(expected);
    });

    it('should not treat falsey string as missing', () async {
      var cache = getCache();
      var paths = [
        ['falsey', 'string']
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [];
      expect(out).toEqual(expected);
    });

    it('should not treat falsey number as missing', () async {
      var cache = getCache();
      var paths = [
        ['falsey', 'number']
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [];
      expect(out).toEqual(expected);
    });

    it('should not treat falsey boolean as missing', () async {
      var cache = getCache();
      var paths = [
        ['falsey', 'boolean']
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [];
      expect(out).toEqual(expected);
    });

    it('should not treat falsey null as missing', () async {
      var cache = getCache();
      var paths = [
        ['falsey', 'null']
      ];

      var out = optimizePathSets(cache, paths, 50);
      var expected = [];
      expect(out).toEqual(expected);
    });

    it('should throw.', () async {
      var cache = getCache();
      var paths = [
        ['videosList', 'inner', 'summary']
      ];

      var caught = false;
      try {
        optimizePathSets(cache, paths, 50);
      } catch (e) {
        caught = true;
        expect(e.toString()).toEqual('References with inner references are not allowed.');
      }
      expect(caught).toEqual(true);
    });
  });
}

getCache() {
  return {
    'videosList': {
      3: $ref('videos[956]'),
      5: $ref('videos[5]'),
      'double': $ref('videosList[3]'),
      'short': $ref('videos[5].moreKeys'),
      'inner': $ref('videosList[3].inner')
    },
    'videos': {
      5: $atom('title'),

      // Short circuit on primitives
      6: 'a', 7: 1, 8: true, 9: null
    },
    'falsey': {'string': '', 'number': 0, 'boolean': false, 'null': null}
  };
}
