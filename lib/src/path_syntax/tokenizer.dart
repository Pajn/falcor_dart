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
  var _string;
  int _idx;
  var _extended;
  var _nextToken;
  String parseString;

  Tokenizer(string, ext) {
    _string = string;
    _idx = -1;
    _extended = ext;
    parseString = '';
  }

  /**
   * grabs the next token either from the peek operation or generates the
   * next token.
   */
  next() {
    var nextToken = _nextToken != null
        ? _nextToken
        : getNext(this._string, this._idx, this._extended);

    _idx = nextToken.idx;
    _nextToken = false;
    parseString += nextToken.token.token;

    return nextToken.token;
  }

  /**
   * will peak but not increment the tokenizer
   */
  peek() {
    var nextToken = _nextToken != null
        ? _nextToken
        : getNext(this._string, this._idx, this._extended);
    _nextToken = nextToken;

    return nextToken.token;
  }

  static int toNumber(x) {
    if (!isNaN(x)) {
      return x;
    }
    return NaN;
  }
}

toOutput(token, type, done) {
  return {'token': token, 'done': done, 'type': type};
}

getNext(string, idx, ext) {
  var output = false;
  var token = '';
  var specialChars = ext ? EXT_SPECIAL_CHARACTERS : SPECIAL_CHARACTERS;
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
    else if (token.length) {
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

  if (!output && token.length) {
    output = toOutput(token, TokenTypes.token, false);
  }

  if (!output) {
    output = {done: true};
  }

  return {'token': output, 'idx': idx};
}
