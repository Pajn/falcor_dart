import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/src/types/range.dart';
import 'package:falcor_dart/src/path_utils/paths_complement_from_tree.dart';
import 'package:falcor_dart/src/path_utils/paths_complement_from_length_tree.dart';

main() {
  describe('pathsComplementFromTree and LengthTree', () {
    it('should strip the single path from tree.', () {
      var paths = [
        ['one', 'two']
      ];
      var tree = {
        'one': {'two': null}
      };
      var out = pathsComplementFromTree(paths, tree);
      expect(out).toEqual([]);
    });

    it('should not strip the single path from tree.', () {
      var paths = [
        ['one', 'two']
      ];
      var tree = {
        'one': {'too': null}
      };
      var out = pathsComplementFromTree(paths, tree);
      expect(out).toEqual([
        ['one', 'two']
      ]);
    });

    it('should strip out one of the two paths, has complex paths.', () {
      var paths = [
        [
          'one',
          new Range(0, 1),
          'two'
        ],
        [
          'one',
          new Range(0, 2),
          'two'
        ]
      ];
      var tree = {
        'one': {
          0: {'two': null},
          1: {'two': null}
        }
      };
      var out = pathsComplementFromTree(paths, tree);
      expect(out).toEqual([
        [
          'one',
          new Range(0, 2),
          'two'
        ]
      ]);
    });

    it('should strip the single path from length tree.', () {
      var paths = [
        ['one', 'two']
      ];
      var tree = {
        2: {
          'one': {'two': null}
        }
      };
      var out = pathsComplementFromLengthTree(paths, tree);
      expect(out).toEqual([]);
    });

    it('should not strip the single path from length tree.', () {
      var paths = [
        ['one', 'two']
      ];
      var tree = {
        2: {
          'one': {'too': null}
        }
      };
      var out = pathsComplementFromLengthTree(paths, tree);
      expect(out).toEqual([
        ['one', 'two']
      ]);
    });

    it('should strip out one of the two paths, has complex paths from length tree.',
        () {
      var paths = [
        [
          'one',
          new Range(0, 1),
          'two'
        ],
        [
          'one',
          new Range(0, 2),
          'two'
        ]
      ];
      var tree = {
        3: {
          'one': {
            0: {'two': null},
            1: {'two': null}
          }
        }
      };
      var out = pathsComplementFromLengthTree(paths, tree);
      expect(out).toEqual([
        [
          'one',
          new Range(0, 2),
          'two'
        ]
      ]);
    });
  });
}
