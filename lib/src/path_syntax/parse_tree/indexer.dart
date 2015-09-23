library falcor_dart.indexer;

import 'package:falcor_dart/src/path_syntax/token_types.dart';
import 'package:falcor_dart/src/path_syntax/parse_tree/range.dart';
import 'package:falcor_dart/src/path_syntax/parse_tree/routed.dart';
import 'package:falcor_dart/src/path_syntax/parse_tree/quote.dart';
import 'package:falcor_dart/src/path_syntax/tokenizer.dart';
import 'package:falcor_dart/src/utils.dart';

/**
 * The indexer is all the logic that happens in between
 * the '[', opening bracket, and ']' closing bracket.
 */
void indexer(Tokenizer tokenizer, openingToken, Map state, out) {
  var token = tokenizer.next();
  var done = false;
  var allowedMaxLength = 1;
  var routedIndexer = false;

  // State variables
  state['indexer'] = [];

  while (!token['done']) {
    switch (token['type']) {
      case TokenTypes.token:
      case TokenTypes.quote:

        // ensures that token adders are properly delimited.
        if (state['indexer'].length == allowedMaxLength) {
          throw 'Indexers require commas between indexer args. -- ${tokenizer.parseString}';
        }
        break;
    }

    switch (token['type']) {
      // Extended syntax case
      case TokenTypes.openingBrace:
        routedIndexer = true;
        routed(tokenizer, token, state);
        break;

      case TokenTypes.token:
        var t = parseNum(token['token']);
        if (t.isNaN) {
          throw 'unquoted indexers must be numeric. -- ${tokenizer.parseString}';
        }
        state['indexer'].add(t);
        break;

      // dotSeparators at the top level have no meaning
      case TokenTypes.dotSeparator:
        if (state['indexer'].length == 0) {
          throw 'Indexers cannot have leading dots. -- ${tokenizer.parseString}';
        }
        range(tokenizer, token, state);
        break;

      // Spaces do nothing.
      case TokenTypes.space:
        break;

      case TokenTypes.closingBracket:
        done = true;
        break;

      // The quotes require their own tree due to what can be in it.
      case TokenTypes.quote:
        quote(tokenizer, token, state);
        break;

      // Its time to decend the parse tree.
      case TokenTypes.openingBracket:
        throw 'Indexers cannot be nested. -- ${tokenizer.parseString}';
        break;

      case TokenTypes.commaSeparator:
        ++allowedMaxLength;
        break;

      default:
        throw 'Unexpected token. -- ${tokenizer.parseString}';
        break;
    }

    // If done, leave loop
    if (done) {
      break;
    }

    // Keep cycling through the tokenizer.
    token = tokenizer.next();
  }

  if (state['indexer'].isEmpty) {
    throw 'cannot have empty indexers. -- ${tokenizer.parseString}';
  }

  if (state['indexer'].length > 1 && routedIndexer) {
    throw 'Only one token can be used per indexer when specifying routed tokens. -- ${tokenizer.parseString}';
  }

  // Remember, if an array of 1, keySets will be generated.
  if (state['indexer'].length == 1) {
    state['indexer'] = state['indexer'][0];
  }

  out.add(state['indexer']);

  // Clean state.
  state['indexer'] = null;
}
