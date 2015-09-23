import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/router.dart';
import 'package:falcor_dart/src/operations/strip/strip_from_range.dart';

main() {
  describe('stripFromRange', () {
    it('should split into 1 range when first arg === from', () {
      var arg = 0;
      var range = new Range(0, 4);
      var out = stripFromRange(arg, range);

      expect(out).toEqual([
        [0],
        [new Range(1, 4)]
      ]);
    });

    it('should split into 1 range when first arg === to', () {
      var arg = 4;
      var range = new Range(0, 4);
      var out = stripFromRange(arg, range);

      expect(out).toEqual([
        [4],
        [new Range(0, 3)]
      ]);
    });

    it('should split into 2 range when from < firstArg < to', () {
      var arg = 2;
      var range = new Range(0, 4);
      var out = stripFromRange(arg, range);

      expect(out).toEqual([
        [2],
        [new Range(0, 1), new Range(3, 4)]
      ]);
    });

    it('should pass in a string number as first argument.', () {
      var arg = '2';
      var range = new Range(0, 4);
      var out = stripFromRange(arg, range);

      expect(out).toEqual([
        [2],
        [new Range(0, 1), new Range(3, 4)]
      ]);
    });

    it('should pass in a routed token as the first argument.', () {
      var arg = getRoutedToken(Keys.keys);
      var range = new Range(0, 4);
      var out = stripFromRange(arg, range);

      expect(out).toEqual([
        [0, 1, 2, 3, 4],
        []
      ]);
    });

    it('should pass in an array with mixed keys.', () {
      var arg = [0, 'one', 2, 'three', 4];
      var range = new Range(0, 4);
      var out = stripFromRange(arg, range);

      expect(out).toEqual([
        [0, 2, 4],
        [new Range(1, 1), new Range(3, 3)]
      ]);
    });

    it('should return nothing when 1 length range is stripped.', () {
      var arg = 0;
      var range = new Range(0, 0);
      var out = stripFromRange(arg, range);

      expect(out).toEqual([
        [0],
        []
      ]);
    });
  });
}

getRoutedToken(type, [name]) {
  return {'type': type, 'named': name != null, 'name': name};
}
