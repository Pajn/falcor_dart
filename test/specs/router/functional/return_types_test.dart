import 'package:guinness2/guinness2.dart';
import 'package:falcor_dart/falcor_dart.dart';
import 'dart:async';

main() {
  describe('return-types', () {
    describe('PathValues', () {
      it('should allow sync returns of a pathValue.', () {
        var ids = [1234];
        run(ids, getPathValues(ids));
      });

      it('should allow sync returns array of pathValues.', () async {
        var ids = [1234, 555];
        run(ids, getPathValues(ids));
      });

      it('should allow async promise returns of a pathValue.', () async {
        var ids = [1234];
        run(ids, promise(getPathValues(ids)));
      });

      it('should allow async promise returns array of pathValues.', () async {
        var ids = [1234, 555];
        run(ids, promise(getPathValues(ids)));
      });

      it('should allow async observable returns of a pathValue.', () async {
        var ids = [1234];
        run(ids, promise(getPathValues(ids)));
      });

      it('should allow async observable returns array of pathValues.',
          () async {
        var ids = [1234, 555];
        run(ids, promise(getPathValues(ids)));
      });
    });

    describe('Jsong', () {
      it('should allow sync returns of a jsong.', () async {
        var ids = [1234];
        run(ids, getJsong(ids));
      });

      it('should allow sync returns array of jsongs.', () async {
        var ids = [1234, 555];
        run(ids, getJsong(ids));
      });

      it('should allow async promise returns of a jsong.', () async {
        var ids = [1234];
        run(ids, promise(getJsong(ids)));
      });

      it('should allow async promise returns array of jsongs.', () async {
        var ids = [1234, 555];
        run(ids, promise(getJsong(ids)));
      });

      it('should allow async observable returns of a jsong.', () async {
        var ids = [1234];
        run(ids, promise(getJsong(ids)));
      });

      it('should allow async observable returns array of jsongs.', () async {
        var ids = [1234, 555];
        run(ids, promise(getJsong(ids)));
      });
    });
  });
}

getJsong(List ids) {
  return (_) {
    var videos = {};
    for (var i = 0; i < ids.length; ++i) {
      videos[ids[i]] = {'title': 'House of Cards'};
    }
    return {
      'jsonGraph': {'videos': videos}
    };
  };
}

getPathValues(List ids) {
  return (_) {
    var videos = [];
    ids.forEach((id) {
      videos.add({
        'path': ['videos', id, 'title'],
        'value': 'House of Cards'
      });
    });

    return ids.length == 1 ? videos.first : videos;
  };
}

getRouter(fn) {
  return new Router([
    {
      'route': 'videos[{integers:id}].title',
      'get': (aliasMap) {
        return fn(aliasMap);
      }
    }
  ]);
}

run(ids, dataFn) async {
  var router = getRouter(dataFn);


  var value = await router.get([
    ['videos', ids, 'title']
  ]);

  expect(value).toEqual(getExpected(ids));
}

getExpected(ids) {
  return getJsong(ids)(ids);
}

promise(fn) {
  return (_) {
    return new Future.value(fn(_));
  };
}
