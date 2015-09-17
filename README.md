# falcor_dart
[![Build Status](https://travis-ci.org/Pajn/falcor_dart.svg?branch=master)](https://travis-ci.org/Pajn/falcor_dart)

This is [Falcor](http://netflix.github.io/falcor/) router implementation for dart.

And as the falcor team states: **This release is a developer preview.**

## Usage
A simple usage example:
```dart
import 'package:falcor_dart/falcor_dart.dart';

main() {
  final router = new Router([
      route(
        // match a request for the key "greeting"
        'greeting',
        // respond with a PathValue with the value of "Hello World."
        get: (path) {
          return {
            'path': ['greeting'],
            'value': 'Hello World'
          };
        }
      )
  ]);
}
```

## More information
For in-depth information on the Falcor Router, see the Router Guide in the
[Falcor Website](http://netflix.github.io/falcor).

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Pajn/falcor_dart
