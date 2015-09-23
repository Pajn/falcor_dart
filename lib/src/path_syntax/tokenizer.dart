library falcor_dart.tokenizer;

import 'package:falcor_dart/src/path_syntax/token_types.dart';

const DOT_SEPARATOR = '.';
const COMMA_SEPARATOR = ',';
const OPENING_BRACKET = '[';
const CLOSING_BRACKET = ']';
const OPENING_BRACE = '{';
const CLOSING_BRACE = '}';
const COLON = ':';
const ESCAPE = '\\';
const DOUBLE_OUOTES = '"';
const SINGE_OUOTES = "'";
const SPACE = " ";
const SPECIAL_CHARACTERS = '\\\'"[]., ';
const EXT_SPECIAL_CHARACTERS = '\\{}\'"[]., :';

class Tokenizer {
  String _string;
  int _idx;
  var _extended;
  var _nextToken;
  String parseString;

  Tokenizer(this._string, this._extended) {
    _idx = -1;
    parseString = '';
  }

  /// grabs the next token either from the peek operation or generates the
  /// next token.
  Map next() {
    var nextToken = _nextToken == true
        ? _nextToken
        : getNext(this._string, this._idx, this._extended);

    _idx = nextToken['idx'];
    _nextToken = false;
    if (nextToken['token'].containsKey('token')) {
      parseString += nextToken['token']['token'];
    }

    return nextToken['token'];
  }

  /// will peak but not increment the tokenizer
  Map peek() {
    var nextToken = _nextToken == true
        ? _nextToken
        : getNext(this._string, this._idx, this._extended);
    _nextToken = nextToken;

    return nextToken['token'];
  }
}

Map toOutput(token, type, bool done) {
  return {'token': token, 'done': done, 'type': type};
}

getNext(String string, int idx, ext) {
  var output;
  var token = '';
  var specialChars =
      (ext != null) ? EXT_SPECIAL_CHARACTERS : SPECIAL_CHARACTERS;
  var done;
  do {
    done = idx + 1 >= string.length;
    if (done) {
      break;
    }

    // we have to peek at the next token
    var character = string[idx + 1];

    if (character != null && specialChars.indexOf(character) == -1) {
      token += character;
      ++idx;
      continue;
    }

    // The token to delimiting character transition.
    else if (token.length > 0) {
      break;
    }

    ++idx;
    var type;
    switch (character) {
      case DOT_SEPARATOR:
        type = TokenTypes.dotSeparator;
        break;
      case COMMA_SEPARATOR:
        type = TokenTypes.commaSeparator;
        break;
      case OPENING_BRACKET:
        type = TokenTypes.openingBracket;
        break;
      case CLOSING_BRACKET:
        type = TokenTypes.closingBracket;
        break;
      case OPENING_BRACE:
        type = TokenTypes.openingBrace;
        break;
      case CLOSING_BRACE:
        type = TokenTypes.closingBrace;
        break;
      case SPACE:
        type = TokenTypes.space;
        break;
      case DOUBLE_OUOTES:
      case SINGE_OUOTES:
        type = TokenTypes.quote;
        break;
      case ESCAPE:
        type = TokenTypes.escape;
        break;
      case COLON:
        type = TokenTypes.colon;
        break;
      default:
        type = TokenTypes.unknown;
        break;
    }
    output = toOutput(character, type, false);
    break;
  } while (!done);

  if (output == null && token.length > 0) {
    output = toOutput(token, TokenTypes.token, false);
  }

  if (output == null) {
    output = {'done': true};
  }

  return {'token': output, 'idx': idx};
}
