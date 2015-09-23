import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/router.dart';
import 'package:falcor_dart/src/operations/strip/strip_from_array.dart';

main() {
  describe('stripFromArray', () {
    it('should strip out all elements if keys used.', () {
      var arg = getRoutedToken(Keys.keys);
      var array = ['one', 2, 'three'];
      var out = stripFromArray(arg, array);
      expect(out).toEqual([
        ['one', 2, 'three'],
        []
      ]);
    });

    it('should strip just the element specified.', () {
      var arg = 'one';
      var array = ['one', 2, 'three'];
      var out = stripFromArray(arg, array);
      expect(out).toEqual([
        ['one'],
        [2, 'three']
      ]);
    });

    it('should strip the array with the range.', () {
      var arg = new Range(0, 3);
      var array = ['one', 2, 'three'];
      var out = stripFromArray(arg, array);
      expect(out).toEqual([
        [2],
        ['one', 'three']
      ]);
    });

    it('should strip the array with an array of ranges.', () {
      var arg = [new Range(0, 1), new Range(2, 2)];
      var array = ['one', 2, 'three'];
      var out = stripFromArray(arg, array);
      expect(out).toEqual([
        [2],
        ['one', 'three']
      ]);
    });

    it('should strip out the values from intersecting ranges, removing a fully matched array.',
        () {
      var arg = 2;
      var array = [new Range(0, 1), new Range(2, 2)];
      var out = stripFromArray(arg, array);
      expect(out).toEqual([
        [2],
        [new Range(0, 1)]
      ]);
    });

    it('should strip out the values from intersecting ranges, splitting a partially matched array.',
        () {
      var arg = 2;
      var array = [new Range(0, 3)];
      var out = stripFromArray(arg, array);
      expect(out).toEqual([
        [2],
        [new Range(0, 1), new Range(3, 3)]
      ]);
    });
  });
}

getRoutedToken(type, [name]) {
  return {'type': type, 'named': name != null, 'name': name};
}
