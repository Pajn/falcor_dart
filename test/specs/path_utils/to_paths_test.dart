import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/src/path_utils/to_path.dart';
import 'package:falcor_dart/src/path_utils/to_tree.dart';
import 'package:falcor_dart/src/types/range.dart';

main() {
  describe('toPaths', () {
    it('toPaths a pathmap that has overlapping branch and leaf nodes', () {
      var pathMaps = [
        null,
        {'lolomo': 1},
        {
          'lolomo': {'summary': 1, 13: 1, 14: 1}
        },
        {
          'lolomo': {
            15: {'rating': 1, 'summary': 1},
            13: {'summary': 1},
            16: {'rating': 1, 'summary': 1},
            14: {'summary': 1},
            17: {'rating': 1, 'summary': 1}
          }
        }
      ];

      var paths = toPaths(pathMaps)
        ..sort((a, b) {
          return a.length - b.length;
        });

      var first = paths[0];
      var second = paths[1];
      var third = paths[2];
      var fourth = paths[3];

      expect(first[0] == 'lolomo').toEqual(true);

      expect((second[0] == 'lolomo') &&
          (second[1][0] == 13) &&
          (second[1][1] == 14) &&
          (second[1][2] == 'summary')).toEqual(true);

      expect((third[0] == 'lolomo') &&
          (third[1].from == 13) &&
          (third[1].to == 14) &&
          (third[2] == 'summary')).toEqual(true);

      expect((fourth[0] == 'lolomo') &&
          (fourth[1].from == 15) &&
          (fourth[1].to == 17) &&
          (fourth[2][0] == 'rating') &&
          (fourth[2][1] == 'summary')).toEqual(true);
    });

    it('should explode a simplePath.', () {
      var out = ['one', 'two'];
      var input = {
        2: {
          'one': {'two': null}
        }
      };

      expect(toPaths(input)).toEqual([out]);
    });

    it('should explode a complex.', () {
      var input = {
        2: {
          'one': {'two': null, 'three': null}
        }
      };
      var out = [
        'one',
        ['three', 'two']
      ];
      var output = toPaths(input);
      output[0][1].sort();

      expect(output).toEqual([out]);
    });

    it('should explode a set of complex and simple paths.', () {
      var out = [
        [
          'one',
          ['three', 'two']
        ],
        ['one', new Range(0, 3), 'summary']
      ];
      var input = {
        2: {
          'one': {'three': null, 'two': null}
        },
        3: {
          'one': {
            0: {'summary': null},
            1: {'summary': null},
            2: {'summary': null},
            3: {'summary': null}
          }
        }
      };

      var output = toPaths(input);
      if (output[0][1] is! List) {
        var tmp = output[0];
        output[0] = output[1];
        output[1] = tmp;
      }

      output[0][1].sort();

      expect(output).toEqual(out);
    });

    it('should translate between toPaths and toTrees', () {
      var expectedTree = {
        'one': {
          0: {'summary': null},
          1: {'summary': null},
          2: {'summary': null},
          3: {'summary': null},
          'three': null,
          'two': null
        }
      };
      var treeMap = {
        2: {
          'one': {'three': null, 'two': null}
        },
        3: {
          'one': {
            0: {'summary': null},
            1: {'summary': null},
            2: {'summary': null},
            3: {'summary': null}
          }
        }
      };

      expect(toTree(toPaths(treeMap))).toEqual(expectedTree);
    });

    it('should not take too much time with many references', () {
      var input = {};
      for (int i = 0; i < 20; i++) {
        input[i] = {'two': null};
      }

      var startTime = new DateTime.now();
      toPaths({3: {'one': input}});
      var endTime = new DateTime.now();

      expect(endTime.difference(startTime).inMilliseconds).toBeLessThan(100);
    });
  });
}
