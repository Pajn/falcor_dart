library falcor_dart.jsong_merge;

import 'package:falcor_dart/src/path_utils/iterate_key_set.dart';
import 'package:falcor_dart/src/utils.dart';
import 'package:falcor_dart/src/cache/path_value_merge.dart';
import 'package:falcor_dart/src/types/sentinels.dart';

/**
 * merges jsong into a seed
 */
Map jsongMerge(Map cache, jsongEnv) {
  var paths = jsongEnv['paths'];
  var j = jsongEnv['jsonGraph'];
  var references = [];
  var values = [];


  paths.forEach((p) {
    merge({
    'cacheRoot': cache,
    'messageRoot': j,
    'references': references,
    'values': values,
    'requestedPath': [],
    'requestIdx': -1,
    'ignoreCount': 0
    }, cache, j, 0, p);
  });

  return {
    'references': references,
    'values': values
  };
}

merge(Map config, cache, message, depth, path, [fromParent, fromKey]) {
  var cacheRoot = config['cacheRoot'];
  var messageRoot = config['messageRoot'];
  var requestedPath = config['requestedPath'];
  var ignoreCount = config['ignoreCount'];
  var requestIdx = config['requestIdx'];
  var updateRequestedPath = ignoreCount <= depth;
  if (updateRequestedPath) {
    requestIdx = ++config['requestIdx'];
  }

  // The message at this point should always be defined.
  // Reached the end of the JSONG message path
  if (message == null || message is! Map || message[r'$type'] != null) {
    fromParent[fromKey] = clone(message);

    // NOTE: If we have found a reference at our cloning position
    // and we have resolved our path then add the reference to
    // the unfulfilledRefernces.
    if (message is Sentinel && message.isRef) {
      var references = config['references'];
      references.add({
        'path': new List.from(requestedPath),
        'value': message.value
      });
    }

    // We are dealing with a value.  We need this for call
    // Call needs to report all of its values into the jsongCache
    // and paths.
    else {
      var values = config['values'];
      values.add({
        'path': new List.from(requestedPath),
        'value': (message is Sentinel && message.type != null) ? message.value : message
      });
    }

    return;
  }

  var outerKey = path[depth];
  var iteratorNote = {};
  var key;
  key = iterateKeySet(outerKey, iteratorNote);

  // We always attempt this as a loop.  If the memo exists then
  // we assume that the permutation is needed.
  do {

    // If the cache exists and we are not at our height, then
    // just follow cache, else attempt to follow message.
    var cacheRes = cache[key];
    var messageRes = message[key];

    var nextPath = path;
    var nextDepth = depth + 1;

    if (updateRequestedPath) {
      if (requestIdx == requestedPath.length) {
        requestedPath.add(key);
      } else if (requestIdx > requestedPath.length) {
        requestedPath.length = requestIdx;
        requestedPath.add(key);
      } else {
        requestedPath[requestIdx] = key;
      }
    }

    // Cache does not exist but message does.
    if (cacheRes == null) {
      cacheRes = cache[key] = {};
    }

    // TODO: Can we hit a leaf node in the cache when traversing?

    // TODO(Jesper): JS version treats undefined here so we cannot treat null...
    if (messageRes != 'undefined') {
      var nextIgnoreCount = ignoreCount;

      // TODO: Potential performance gain since we know that
      // references are always pathSets of 1, they can be evaluated
      // iteratively.

      // There is only a need to consider message references since the
      // merge is only for the path that is provided.
      if (messageRes != null && messageRes is Sentinel && messageRes.isRef && depth < path.length - 1) {
        nextDepth = 0;
        nextPath = catAndSlice(messageRes.value, path, depth + 1);
        cache[key] = messageRes;

        // Reset position in message and cache.
        nextIgnoreCount = messageRes.value.length;
        messageRes = messageRoot;
        cacheRes = cacheRoot;
      }

      // move forward down the path progression.
      config['ignoreCount'] = nextIgnoreCount;
      merge(config, cacheRes, messageRes,
          nextDepth, nextPath, cache, key);
      config['ignoreCount'] = ignoreCount;
    }

    // The second the incoming jsong must be fully qualified,
    // anything that is not will be materialized into the provided cache
    else {

      // do not materialize, continue down the cache.
      if (depth < path.length - 1) {
        merge(config, cacheRes, {}, nextDepth, nextPath, cache, key);
      }

      // materialize the node
      else {
        cache[key] = {r'$type': r'$atom'};
      }
    }

    if (updateRequestedPath) {
      requestedPath.length = requestIdx;
    }

    // Are we done with the loop?
    key = iterateKeySet(outerKey, iteratorNote);
  } while (!iteratorNote['done']);
}
