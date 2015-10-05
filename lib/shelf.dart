library falcor_dart.shelf;

import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart' as shelf;
import 'package:falcor_dart/router.dart';
import 'package:falcor_dart/src/jsonSerializer.dart';

var parseArgs = {
  'jsonGraph': true,
  'callPath': true,
  'arguments': true,
  'pathSuffixes': true,
  'paths': true
};

typedef Future<shelf.Response> FalcorHandler(shelf.Request request);

FalcorHandler createFalcorHandler(getDataSource) {
  return (shelf.Request request) async {
    var jsonGraphEnvelope;

    Map context = await requestToContext(request);
    Router router = getDataSource(request);

    if (context.keys.contains('error')) {
      return new shelf.Response(400, body: JSON.encode(context));
    }

    if (context.keys.isEmpty) {
      return new shelf.Response.internalServerError(
          body: JSON.encode({'error': 'Request not supported'}));
    }
    if (context['method'] == null || context['method'].isEmpty) {
      return new shelf.Response.internalServerError(
          body: JSON.encode({'error': 'No query method provided'}));
    }
    if (context['method'] != 'set' &&
        (context['paths'] is! List ||
            context['paths'].any((path) => path is! List))) {
      return new shelf.Response.internalServerError(
          body: JSON.encode({'error': 'Paths must be a set of paths'}));
    }

    try {
      if (context['method'] == 'get') {
        jsonGraphEnvelope = await router.get(context['paths']);
      } else if (context['method'] == 'set') {
        jsonGraphEnvelope = await router.set(context['jsonGraph']);
      } else if (context['method'] == 'call') {
        jsonGraphEnvelope = await router.call(context['callPath'],
            context['arguments'], context['pathSuffixes'], context['paths']);
      } else {
        return new shelf.Response.internalServerError(
            body: JSON.encode({'error': 'Data source does not implement the requested method'}));
      }
    } catch (e) {
      rethrow;
      return new shelf.Response.internalServerError(body: JSON.encode({'error': e.toString()}));
    }

    return new shelf.Response.ok(
        JSON.encode(jsonGraphEnvelope, toEncodable: serializeToJson));
  };
}

Future<Map> requestToContext(shelf.Request request) async {
  var queryMap = request.method == 'POST'
      ? JSON.decode(await request.readAsString())
      : Uri.parse(request.requestedUri.toString()).queryParameters;

  var context = {};
  if (queryMap != null && !queryMap.isEmpty) {
    queryMap.keys.forEach((key) {
      var arg = queryMap[key];

      if (parseArgs[key] != null && arg != null) {
        try {
          context[key] = JSON.decode(arg);
        } catch (e) {
          context['error'] = 'Paths parameter is invalid JSON';
        }
      } else {
        context[key] = arg;
      }
    });
  }

  return context;
}
