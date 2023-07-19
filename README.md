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

A Dart Simple Queue System based on ChangeNotifier.

## Getting started

Either run:
```bash
fluter pub add flutter_sqs
```

or add to pubspec.yaml:

```yaml
flutter_sqs: ^1.0.0
```


## Usage

```dart
import 'package:flutter_sqs/flutter_sqs.dart';

final Queue queue = SingleListenerQueue<Task>(); // single listener
// or
final Queue queue = BroadcastQueue<Task>(); // broadcast queue

// add listeners to the queue

queue.addListener((Task event) {
  // do something with the event
});


final firstTask = Task();

// add values to the queue
queue.add(firstTask);

final secondTask = Task();

queue.add(secondTask);

```

## Additional information

Feel free to file any issues, and any help improving and maintaining is welcome.

Hope it's useful `:)`
