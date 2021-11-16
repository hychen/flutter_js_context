<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

This package enhances the interoperability between Dart and [flutter_js](https://pub.dev/documentation/flutter_js/latest/).

## Features

Use this package to

- Track which variables are defined.
- Decode evaluated results that the type are assumed as JSON always.
- Load JavaScript file properly.

## Getting started

```dart
flutter pub add flutter_js_context
```

## Usage

```dart
import 'package:flutter_js_context/flutter_js_context.dart';

void main() {
  final context = JsContext();

  JsRef obj = JsRef.define(context, 'myvar', '1');

  // equals 'var myvar[ref.key] = 4;' in JavaScript.
  obj.update("4");

  // plus 4 in javascript.
  context.evaluate("${obj.toJsCode()} + 4"); // 8

  // plus javascript value in dart.
  print(obj.value + 4); // 12
}
```

See more usage in the test.
