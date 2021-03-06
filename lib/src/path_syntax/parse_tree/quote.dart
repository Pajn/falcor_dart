library falcor_dart.quote;

import 'package:falcor_dart/src/path_syntax/token_types.dart';
import 'package:falcor_dart/src/path_syntax/tokenizer.dart';

/**
 * quote is all the parse tree in between quotes.  This includes the only
 * escaping logic.
 *
 * parse-tree:
 * <opening-quote>(.|(<escape><opening-quote>))*<opening-quote>
 */
void quote(Tokenizer tokenizer, openingToken, Map state) {
  var token = tokenizer.next();
  var innerToken = '';
  var openingQuote = openingToken['token'];
  var escaping = false;
  var done = false;

  while (!token['done']) {
    switch (token['type']) {
      case TokenTypes.token:
      case TokenTypes.space:

      case TokenTypes.dotSeparator:
      case TokenTypes.commaSeparator:

      case TokenTypes.openingBracket:
      case TokenTypes.closingBracket:
      case TokenTypes.openingBrace:
      case TokenTypes.closingBrace:
        if (escaping) {
          throw 'Invalid escape character.  Only quotes are escapable. -- ${tokenizer.parseString}';
        }

        innerToken += token['token'];
        break;

      case TokenTypes.quote:
        // the simple case.  We are escaping
        if (escaping) {
          innerToken += token['token'];
          escaping = false;
        }

        // its not a quote that is the opening quote
        else if (token['token'] != openingQuote) {
          innerToken += token['token'];
        }

        // last thing left.  Its a quote that is the opening quote
        // therefore we must produce the inner token of the indexer.
        else {
          done = true;
        }

        break;
      case TokenTypes.escape:
        escaping = true;
        break;

      default:
        throw 'Unexpected token. -- ${tokenizer.parseString}';
    }

    // If done, leave loop
    if (done) {
      break;
    }

    // Keep cycling through the tokenizer.
    token = tokenizer.next();
  }

  if (innerToken.isEmpty) {
    throw 'cannot have empty quoted keys. -- ${tokenizer.parseString}';
  }

  state['indexer'].add(innerToken);
}
