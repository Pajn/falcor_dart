library falcor_dart.iterate_key_set;

import 'package:falcor_dart/src/types/range.dart';


/**
 * Takes in a keySet and a note attempts to iterate over it.
 * If the value is a primitive, the key will be returned and the note will
 * be marked done
 * If the value is an object, then each value of the range will be returned
 * and when finished the note will be marked done.
 * If the value is an array, each value will be iterated over, if any of the
 * inner values are ranges, those will be iterated over.  When fully done,
 * the note will be marked done.
 *
 * @param {Object|Array|String|Number} keySet -
 * @param {Object} note - The non filled note
 * @returns {String|Number|undefined} - The current iteration value.
 * If undefined, then the keySet is empty
 * @public
 */
iterateKeySet(keySet, Map note) {
  if (note['isArray'] == null) {
    initializeNote(keySet, note);
  }

  // Array iteration
  if (note['isArray']) {
    var nextValue;

    // Cycle through the array and pluck out the next value.
    do {
      if (note['loaded'] != null && note['rangeOffset'] > note['to']) {
        ++note['arrayOffset'];
        note['loaded'] = false;
      }

      var idx = note['arrayOffset'], length = keySet.length;
      if (idx >= length) {
        note['done'] = true;
        break;
      }

      var el = keySet[note['arrayOffset']];

      // Inner range iteration.
      if (el is Range) {
        if (!note['loaded']) {
          initializeRange(el, note);
        }

        // Empty to/from
        if (note['empty']) {
          continue;
        }

        nextValue = note['rangeOffset']++;
      }

      // Primitive iteration in array.
      else {
        ++note['arrayOffset'];
        nextValue = el;
      }
    } while (nextValue == null);

    return nextValue;
  }

  // Range iteration
  else if (note['isRange']) {
    if (note['loaded'] == null) {
      initializeRange(keySet, note);
    }
    if (note['rangeOffset'] > note['to']) {
      note['done'] = true;
      return null;
    }

    return note['rangeOffset']++;
  }

  // Primitive value
  else {
    note['done'] = true;
    return keySet;
  }
}

initializeRange(Range key, Map memo) {
  var from = memo['from'] = key.from ?? 0;
  var to = memo['to'] = key.to ??
                     ((key.length != null) ? memo['from'] + key.length - 1 : 0);
  memo['rangeOffset'] = memo['from'];
  memo['loaded'] = true;
  if (from > to) {
    memo['empty'] = true;
  }
}

initializeNote(key, Map note) {
  note['done'] = false;
  note['isRange'] = key is Range;
  note['isArray'] = key is List;
  note['arrayOffset'] = 0;
}
