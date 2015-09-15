import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/src/operations/strip/strip_path.dart';
import 'package:falcor_dart/falcor_dart.dart';

main() {
  describe('Strip Path', () {
    describe('Fully Matched Paths', () {
      it('should fully match a path with simple keys.', () {
        var matchedPath = ['A', 'B', 'C'];
        var virtualPath = ['A', 'B', 'C'];
        var out = stripPath(matchedPath, virtualPath);
        expect(out).toEqual([
          ['A', 'B', 'C'],
          []
        ]);
      });

      it('should fully match a path with simple keys and a virtual path with routedTokens.',
          () {
        var matchedPath = ['A', 'B', 'C'];
        var virtualPath = ['A', getRoutedToken(Keys.keys), 'C'];
        var out = stripPath(matchedPath, virtualPath);
        expect(out).toEqual([
          ['A', 'B', 'C'],
          []
        ]);
      });

      it('should fully match a path with array args.', () {
        var matchedPath = [
          'A',
          ['B', 'D'],
          'C'
        ];
        var virtualPath = ['A', getRoutedToken(Keys.keys), 'C'];
        var out = stripPath(matchedPath, virtualPath);
        expect(out).toEqual([
          [
            'A',
            ['B', 'D'],
            'C'
          ],
          []
        ]);
      });

      //todo(Rasmus): Fix, returns range.toList() instead of range
      xit('should fully match a path with range args.', () {
        var matchedPath = ['A', new Range(0, 5), 'C'];
        var virtualPath = ['A', getRoutedToken(Keys.keys), 'C'];
        var out = stripPath(matchedPath, virtualPath);
        expect(out).toEqual([
          ['A', new Range(0, 5), 'C'],
          []
        ]);
      });
    });

    describe('Partially Matched Paths', () {
      it('should partially match a path with array keys.', () {
        var matchedPath = [
          'A',
          ['B', 'D'],
          'C'
        ];
        var virtualPath = ['A', 'B', 'C'];
        var out = stripPath(matchedPath, virtualPath);
        expect(out).toEqual([
          ['A', 'B', 'C'],
          [
            ['A', 'D', 'C']
          ]
        ]);
      });

      it('should partially match a path with range.', () {
        var matchedPath = ['A', new Range(0, 5), 'C'];
        var virtualPath = ['A', 1, 'C'];
        var out = stripPath(matchedPath, virtualPath);
        expect(out).toEqual([
          ['A', 1, 'C'],
          [
            [
              'A',
              [new Range(0, 0), new Range(2, 5)],
              'C'
            ]
          ]
        ]);
      });

      it('should partially match a path with array range.', () {
        var matchedPath = [
          'A',
          [new Range(0, 2), new Range(5, 5)],
          'C'
        ];
        var virtualPath = ['A', 1, 'C'];
        var out = stripPath(matchedPath, virtualPath);
        expect(out).toEqual([
          ['A', 1, 'C'],
          [
            [
              'A',
              [new Range(0, 0), new Range(2, 2), new Range(5, 5)],
              'C'
            ]
          ]
        ]);
      });

      it('should test a multiple relative complement partial match.', () {
        var matchedPath = [
          ['A', 'B'],
          ['C', 'D'],
          ['E', 'F']
        ];
        var virtualPath = ['A', 'C', 'E'];
        var out = stripPath(matchedPath, virtualPath);
        expect(out).toEqual([
          ['A', 'C', 'E'],
          [
            [
              'B',
              ['C', 'D'],
              ['E', 'F']
            ],
            [
              'A',
              'D',
              ['E', 'F']
            ],
            ['A', 'C', 'F']
          ]
        ]);
      });
    });
  });
}

getRoutedToken(type, [name]) {
  return {'type': type, 'named': name != null, 'name': name};
}
