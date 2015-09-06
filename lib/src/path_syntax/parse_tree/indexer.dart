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
          E.throwError(idxE.requiresComma, tokenizer);
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
          E.throwError(idxE.needQuotes, tokenizer);
        }
        state['indexer'].add(t);
        break;

      // dotSeparators at the top level have no meaning
      case TokenTypes.dotSeparator:
        if (state['indexer'].length == 0) {
          E.throwError(idxE.leadingDot, tokenizer);
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
        E.throwError(idxE.nested, tokenizer);
        break;

      case TokenTypes.commaSeparator:
        ++allowedMaxLength;
        break;

      default:
        E.throwError(E.unexpectedToken, tokenizer);
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
    E.throwError(idxE.empty, tokenizer);
  }

  if (state['indexer'].length > 1 && routedIndexer) {
    E.throwError(idxE.routedTokens, tokenizer);
  }

  // Remember, if an array of 1, keySets will be generated.
  if (state['indexer'].length == 1) {
    state['indexer'] = state['indexer'][0];
  }

  out.add(state['indexer']);

  // Clean state.
  state['indexer'] = null;
}
