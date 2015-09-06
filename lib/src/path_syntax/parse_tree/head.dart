library falcor_dart.head;

import 'package:falcor_dart/src/path_syntax/token_types.dart';
import 'package:falcor_dart/src/path_syntax/parse_tree/indexer.dart';
import 'package:falcor_dart/src/utils.dart';
import 'package:falcor_dart/src/path_syntax/tokenizer.dart';

/**
 * The top level of the parse tree.  This returns the generated path
 * from the tokenizer.
 */
List head(Tokenizer tokenizer) {
  var token = tokenizer.next();
  var state = {};
  var out = [];

  while (token['done'] != true) {

    switch (token['type']) {
      case TokenTypes.token:
//        var first = +token.token[0];
//        if (!isNaN(first)) {
//          E.throwError(E.invalidIdentifier, tokenizer);
//        }

        if (isNumeric(token['token'][0])) {
          throw 'Invalid Identifier. -- ${tokenizer.parseString}';
//          E.throwError(E.invalidIdentifier, tokenizer);
        }
        out.add(token['token']);
        break;

      // dotSeparators at the top level have no meaning
      case TokenTypes.dotSeparator:
        if (out.isEmpty) {
          E.throwError(E.unexpectedToken, tokenizer);
        }
        break;

      // Spaces do nothing.
      case TokenTypes.space:
        // NOTE: Spaces at the top level are allowed.
        // titlesById  .summary is a valid path.
        break;


      // Its time to decend the parse tree.
      case TokenTypes.openingBracket:
        indexer(tokenizer, token, state, out);
        break;

      default:
        E.throwError(E.unexpectedToken, tokenizer);
        break;
    }

    // Keep cycling through the tokenizer.
    token = tokenizer.next();
  }

  if (out.isEmpty) {
    E.throwError(E.invalidPath, tokenizer);
  }

  return out;
}
