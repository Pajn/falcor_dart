library falcor_dart.range;

import 'package:falcor_dart/src/path_syntax/token_types.dart';
import 'package:falcor_dart/src/path_syntax/tokenizer.dart';
import 'package:falcor_dart/src/utils.dart';

/**
 * The indexer is all the logic that happens in between
 * the '[', opening bracket, and ']' closing bracket.
 */
void range(Tokenizer tokenizer, openingToken, Map state) {
  var token = tokenizer.peek();
  var dotCount = 1;
  var done = false;
  var inclusive = true;

  // Grab the last token off the stack.  Must be an integer.
  var idx = state['indexer'].length - 1;
  var from = parseNum(state['indexer'][idx]);
  var to;

  if (from.isNaN) {
    throw 'ranges must be preceded by numbers. -- ${tokenizer.parseString}';
  }

  // Why is number checking so difficult in javascript.

  while (!done && !token['done']) {
    switch (token['type']) {

      // dotSeparators at the top level have no meaning
      case TokenTypes.dotSeparator:
        if (dotCount == 3) {
          throw 'Unexpected token. -- ${tokenizer.parseString}';
        }
        ++dotCount;

        if (dotCount == 3) {
          inclusive = false;
        }
        break;

      case TokenTypes.token:
        // move the tokenizer forward and save to.
        to = parseNum(tokenizer.next()['token']);

        // throw potential error.
        if (to.isNaN) {
          throw 'ranges must be suceeded by numbers. -- ${tokenizer.parseString}';
        }

        done = true;
        break;

      default:
        done = true;
        break;
    }

    // Keep cycling through the tokenizer.  But ranges have to peek
    // before they go to the next token since there is no 'terminating'
    // character.
    if (!done) {
      tokenizer.next();

      // go to the next token without consuming.
      token = tokenizer.peek();
    }

    // break and remove state information.
    else {
      break;
    }
  }

  state['indexer'][idx] = {'from': from, 'to': inclusive ? to : to - 1};
}
