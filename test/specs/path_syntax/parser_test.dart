library falcor_dart.parser_test;

import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/path_syntax.dart';

main() {
  describe('parser', () {
    it('should parse a simple key string', () {
      var out = parse('one.two.three');
      expect(out).toEqual(['one', 'two', 'three']);
    });
    it('should parse a string with indexers', () {
      var out = parse('one[0]');
      expect(out).toEqual(['one', 0]);
    });
    it('should parse a string with indexers followed by dot separators.', () {
      var out = parse('one[0].oneMore');
      expect(out).toEqual(['one', 0, 'oneMore']);
    });
    it('should parse a string with a range', () {
      var out = parse('one[0..5].oneMore');
      expect(out).toEqual([
        'one',
        {'from': 0, 'to': 5},
        'oneMore'
      ]);
    });
    it('should parse a string with a set of tokens', () {
      var out = parse('one["test", \'test2\'].oneMore');
      expect(out).toEqual([
        'one',
        ['test', 'test2'],
        'oneMore'
      ]);
    });
    it('should treat 07 as 7', () {
      var out = parse('one[07, 0001].oneMore');
      expect(out).toEqual([
        'one',
        [7, 1],
        'oneMore'
      ]);
    });
    it('should parse out a range.', () {
      var out = parse('one[0..1].oneMore');
      expect(out).toEqual([
        'one',
        {'from': 0, 'to': 1},
        'oneMore'
      ]);
    });
    it('should parse out multiple ranges.', () {
      var out = parse('one[0..1,3..4].oneMore');
      expect(out).toEqual([
        'one',
        [
          {'from': 0, 'to': 1},
          {'from': 3, 'to': 4}
        ],
        'oneMore'
      ]);
    });

    describe('#fromPath', () {
      it('should convert a string to path.', () {
        var input = 'videos[1234].summary';
        var output = ['videos', 1234, 'summary'];
        expect(parsePath(input)).toEqual(output);
      });

      it('should return a provided array.', () {
        var input = ['videos', 1234, 'summary'];
        var output = ['videos', 1234, 'summary'];
        expect(parsePath(input)).toEqual(output);
      });

      it('should convert null.', () {
        var input;
        var output = [];
        expect(parsePath(input)).toEqual(output);
      });
    });

    describe('#fromPathsOrPathValues', () {
      it('should convert a string to path.', () {
        var input = ['videos[1234].summary'];
        var output = [
          ['videos', 1234, 'summary']
        ];
        expect(parsePathsOrPathValues(input)).toEqual(output);
      });

      it('should convert null to an empty path.', () {
        var input;
        var output = [];
        expect(parsePathsOrPathValues(input)).toEqual(output);
      });

      it('should return a provided array.', () {
        var input = [
          ['videos', 1234, 'summary']
        ];
        var output = [
          ['videos', 1234, 'summary']
        ];
        expect(parsePathsOrPathValues(input)).toEqual(output);
      });

      it('should convert with a bunch of values.', () {
        var input = [
          ['videos', 1234, 'summary'],
          'videos[555].summary',
          {'path': 'videos[444].summary', 'value': 5}
        ];
        var output = [
          ['videos', 1234, 'summary'],
          ['videos', 555, 'summary'],
          {
            'path': ['videos', 444, 'summary'],
            'value': 5
          }
        ];
        expect(parsePathsOrPathValues(input)).toEqual(output);
      });
    });

    describe('#routed', () {
      it('should create a routed token for the path.', () {
        var out = parse('one[{ranges}].oneMore', true);
        expect(out).toEqual([
          'one',
          {'type': 'ranges', 'named': false, 'name': ''},
          'oneMore'
        ]);
      });
      it('should create a named routed token for the path.', () {
        var out = parse('one[{ranges:foo}].oneMore', true);
        expect(out).toEqual([
          'one',
          {'type': 'ranges', 'named': true, 'name': 'foo'},
          'oneMore'
        ]);
      });
    });
  });
}
