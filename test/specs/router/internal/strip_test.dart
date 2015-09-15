import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/falcor_dart.dart';
import 'package:falcor_dart/src/operations/strip/strip.dart';

main() {
  describe('Strip', () {
    it('should split into 1 range when virtualAtom === matchedAtom.from', () {
      var arg = 0;
      var range = new Range(0, 4);
      var out = strip(range, arg);

      expect(out).toEqual([
        0,
        [new Range(1, 4)]
      ]);
    });

    it('should strip out all elements if keys used.', () {
      var arg = getRoutedToken(Keys.keys);
      var array = ['one', 2, 'three'];
      var out = strip(array, arg);
      expect(out).toEqual([
        ['one', 2, 'three'],
        []
      ]);
    });

    it('should match numeric tokens.', () {
      var matchedAtom = 5;
      var virtualAtom = 5;
      var out = strip(matchedAtom, virtualAtom);
      expect(out).toEqual([5, []]);
    });

    it('should match mismatched tokens.', () {
      var matchedAtom = 5;
      var virtualAtom = '5';
      var out = strip(matchedAtom, virtualAtom);
      expect(out).toEqual([5, []]);
    });

    it('should return an empty complement on any routed token with non matched object input.',
        () {
      var matchedAtom = 5;
      var virtualAtom = getRoutedToken(Keys.keys);
      var out = strip(matchedAtom, virtualAtom);
      expect(out).toEqual([5, []]);
    });
  });
}

getRoutedToken(type, [name]) {
  return {'type': type, 'named': name != null, 'name': name};
}
