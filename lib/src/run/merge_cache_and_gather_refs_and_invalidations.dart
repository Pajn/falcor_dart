library falcor_dart.merge_cache_and_gather_refs_and_invalidations;

import 'package:falcor_dart/src/cache/path_value_merge.dart';
import 'package:falcor_dart/src/utils.dart';
import 'package:falcor_dart/src/cache/jsong_merge.dart';

/**
 * takes the response from an action and merges it into the
 * cache.  Anything that is an invalidation will be added to
 * the first index of the return value, and the inserted refs
 * are the second index of the return value.  The third index
 * of the return value is messages from the action handlers
 *
 * @param {Object} cache
 * @param {Array} jsongOrPVs
 */
Map mergeCacheAndGatherRefsAndInvalidations(cache, jsongOrPVs) {
  var references = [];
  var len = -1;
  var invalidations = [];
  var messages = [];
  var values = [];

  jsongOrPVs.forEach((jsongOrPV) {
    var refsAndValues = {};

    if (isMessage(jsongOrPV)) {
      messages.add(jsongOrPV);
    } else if (isJSONG(jsongOrPV)) {
      refsAndValues = jsongMerge(cache, jsongOrPV);
    }

    // Last option are path values.
    else {
      refsAndValues = pathValueMerge(cache, jsongOrPV);
    }

    var refs = refsAndValues['references'];
    var vals = refsAndValues['values'];
    var invs = refsAndValues['invalidations'];

    if (vals is List && vals.isNotEmpty) {
      values.addAll(vals);
    }

    if (invs is List && invs.isNotEmpty) {
      invalidations.addAll(invs);
    }

    if (refs != null && refs.isNotEmpty) {
      references.addAll(refs);
    }
  });

  return {
    'invalidations': invalidations,
    'references': references,
    'messages': messages,
    'values': values
  };
}
