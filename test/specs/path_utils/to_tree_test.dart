import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/src/path_utils/to_tree.dart';
import 'package:falcor_dart/src/path_utils/to_path.dart';
import 'package:falcor_dart/src/types/range.dart';

main() {
  describe('toTree', () {
    it('should explode a simplePath.', () {
      var input = ['one', 'two'];
      var out = {'one': {'two': null}};

      expect(toTree([input])).toEqual(out);
    });

    it('should explode a complex.', () {
      var input = ['one', ['two', 'three']];
      var out = {'one': {'three': null, 'two': null}};

      expect(toTree([input])).toEqual(out);
    });

    it('should explode a set of complex and simple paths.', () {
      var input = [
        [
          'one',
          ['two', 'three']
        ],
        [
          'one',
          {'from': 0, 'to': 3},
          'summary'
        ]
      ];
      var out = {
        'one': {
          'three': null,
          'two': null,
          0: {'summary': null},
          1: {'summary': null},
          2: {'summary': null},
          3: {'summary': null}
        }
      };

      expect(toTree(input)).toEqual(out);
    });

    it('should translate between toPaths and toTrees', () {
      var input = [
        [
          'one',
          ['two', 'three']
        ],
        [
          'one',
          new Range(0, 3),
          'summary'
        ]
      ];
      var treeMap = {
        2: toTree([input[0]]),
        3: toTree([input[1]])
      };
      var output = toPaths(treeMap);
      output[0][1].sort();
      output[0][1] = output[0][1].reversed.toList();

      expect(output).toEqual(input);
    });
  });
}
