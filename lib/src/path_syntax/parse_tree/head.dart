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
        if (isNumeric(token['token'][0])) {
          throw 'Invalid Identifier. -- ${tokenizer.parseString}';
        }
        out.add(token['token']);
        break;

      // dotSeparators at the top level have no meaning
      case TokenTypes.dotSeparator:
        if (out.isEmpty) {
          throw 'Unexpected token. -- ${tokenizer.parseString}';
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
        throw 'Unexpected token. -- ${tokenizer.parseString}';
        break;
    }

    // Keep cycling through the tokenizer.
    token = tokenizer.next();
  }

  if (out.isEmpty) {
    throw 'Please provide a valid path. -- ${tokenizer.parseString}';
  }

  return out;
}
