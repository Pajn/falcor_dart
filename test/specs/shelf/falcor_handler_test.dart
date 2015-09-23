import 'dart:convert';

import 'package:guinness2/guinness2.dart';
import 'package:shelf/shelf.dart';

import 'package:falcor_dart/router.dart';
import 'package:falcor_dart/shelf.dart';

main() {
  describe('router', () {
    describe('Can interact with data correctly', () {
      it('Calls get method', () async {
        // Fake GET request
        var fakeReq = new Request(
            'GET',
            Uri.parse(Uri.encodeFull(
                'http://localhost:8080/?paths=[["genrelist",{"from":0,"to":5},"titles",{"from":0,"to":5},"name"]]&method=get')));

        // set up basic router and immediately invoke the returned funciton
        // with fake req and res objects to check on stubbed functions
        Response response = await createFalcorHandler((req) {
          return new Router([
            route('route', get: (path) {
              return null;
            })
          ]);
        })(fakeReq);

        expect(response.statusCode).toEqual(200);

        // Check that the res.'send': was called with a jsonGraph object
        var sentValue = JSON.decode(await response.readAsString());
        expect(sentValue['jsonGraph']).toBeNotNull();
      });

      it('Calls set method', () async {
        // Fake POST request
        var fakeReq = new Request(
            'POST', Uri.parse(Uri.encodeFull('http://localhost:8080/')),
            body: JSON.encode({
              'jsonGraph':
                  '{"genrelist":{"0":{"titles":{"0":{"name":"jon"}}}},"paths":[["genrelist",0,"titles",0,"name"]]}',
              'method': 'set',
            }));

        // set up basic router and immediately invoke the returned funciton
        // with fake req and res objects to check on stubbed functions
        var response = await createFalcorHandler((req) {
          return new Router([
            {
              'route': 'route',
              'set': (pathSet) {
                return null;
              }
            }
          ]);
        })(fakeReq);

        expect(response.statusCode).toEqual(200);

        // Check that the res.'send': was called with a jsonGraph object
        var sentValue = JSON.decode(await response.readAsString());
        expect(sentValue['jsonGraph']).toBeNotNull();
      });
    });
  });
}
