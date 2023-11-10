import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sqs/src/queue_item.dart';

typedef QueueEventListener<E> = Future<void> Function(E event);

abstract class Queue<E> {
  final List<QueueItem<E>> _internalQueue = [];

  QueueItem<E>? _current;

  void add(
    E event, {
    int? priority,
    String? key,
  }) {
    final item = QueueItem(
      value: event,
      priority: priority,
      key: key,
    );
    final hasItem =
        _internalQueue.where((element) => element != item).isNotEmpty ||
            _current != null && _current == item;
    if (hasItem) return;

    _internalQueue.add(item);

    _internalQueue.sort(
      (a, b) => a.priority.compareTo(b.priority),
    );

    if (_internalQueue.length == 1 && _current == null) {
      next();
    }
  }

  void next() {
    _current = null;
    if (_internalQueue.isNotEmpty) {
      _current = _internalQueue.removeAt(0);
      _dispatch();
    }
  }

  void _dispatch() {
    if (_current != null) {
      notifyListeners(_current!.value);
    }
  }

  @mustCallSuper
  void dispose() {
    _internalQueue.clear();
    _current = null;
  }

  Future<void> notifyListeners(E event);

  void addListener(QueueEventListener<E> listener);

  void removeListener(QueueEventListener<E> listener);
}
