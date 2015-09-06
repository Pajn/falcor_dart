library falcor_dart.routed;

import 'package:falcor_dart/src/path_syntax/token_types.dart';
import 'package:falcor_dart/src/routed_tokens.dart';
import 'package:falcor_dart/src/path_syntax/tokenizer.dart';

/**
 * The routing logic.
 *
 * parse-tree:
 * <opening-brace><routed-token>(:<token>)<closing-brace>
 */
void routed(Tokenizer tokenizer, openingToken, Map state) {
  var routeToken = tokenizer.next();
  var named = false;
  var name = '';

  // ensure the routed token is a valid ident.
  switch (routeToken['token']) {
    case RoutedTokens.integers:
    case RoutedTokens.ranges:
    case RoutedTokens.keys:
    //valid
      break;
    default:
      E.throwError(routedE.invalid, tokenizer);
      break;
  }

  // Now its time for colon or ending brace.
  var next = tokenizer.next();

  // we are parsing a named identifier.
  if (next['type'] == TokenTypes.colon) {
    named = true;

    // Get the token name.
    next = tokenizer.next();
    if (next['type'] != TokenTypes.token) {
      E.throwError(routedE.invalid, tokenizer);
    }
    name = next['token'];

    // move to the closing brace.
    next = tokenizer.next();
  }

  // must close with a brace.

  if (next['type'] == TokenTypes.closingBrace) {
    var outputToken = {
      'type': routeToken['token'],
      'named': named,
      'name': name
    };
    state['indexer'].add(outputToken);
  }

  // closing brace expected
  else {
    E.throwError(routedE.invalid, tokenizer);
  }

}
