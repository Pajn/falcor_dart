import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/falcor_dart.dart';

main() {
  describe('Virtual Collisions', () {
    it('should collide when two paths have the exact same virtual path.', () {
      try {
        new Router([
          {'route': 'videos[{integers}].summary', 'get': () {}},
          {'route': 'videos[{integers}].summary', 'get': () {}}
        ]);
      } catch (e) {
        var str = ['videos', 'integers', 'summary'].join(',');
        expect(e.message)
            .toEqual('Two routes cannot have the same precedence or path. $str');
      }
    });
    it('should not collide when two paths have the exact same virtual path but different ops.',
        () {
      var done = false;
      try {
        new Router([
          {'route': 'videos[{integers}].summary', 'get': () {}},
          {'route': 'videos[{integers}].summary', 'set': () {}}
        ]);
        done = true;
      } catch (e) {
        return done(e);
      }
      expect(done).toBeTrue();
    });
    it('should not collide when two pathSets have the exact same virtual path but different ops.',
        () {
      var done = false;
      try {
        new Router([
          {
            'route': 'videos[{integers}]["summary", "title", "rating"]',
            'get': () {}
          },
          {'route': 'videos[{integers}].rating', 'set': () {}}
        ]);
        done = true;
      } catch (e) {
        return done(e);
      }
      expect(done).toBeTrue();
    });
    it('should collide when two paths have the same virtual path precedence.',
        () {
      try {
        new Router([
          {'route': 'videos[{integers}].summary', 'get': () {}},
          {'route': 'videos[{ranges}].summary', 'get': () {}}
        ]);
      } catch (e) {
        var str = 'videos,ranges,summary';
        expect(e.message)
            .toEqual('Two routes cannot have the same precedence or path. $str');
      }
    });
  });
}
