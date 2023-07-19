import 'dart:async';

typedef QueueEventListener<E> = Future<void> Function(E event);

abstract class Queue<E> {
  final List<E> _internalQueue = [];

  E? _current;

  void add(E event) {
    _internalQueue.add(event);
    if (_internalQueue.length == 1) {
      _dispatch();
    }
  }

  void next() {
    _current = null;
    if (_internalQueue.isNotEmpty) {
      _internalQueue.removeAt(0);
      _dispatch();
    }
  }

  void _dispatch() {
    final first = _internalQueue.firstOrNull;
    if (first != null && first != _current) {
      _current = first;
      notifyListeners(_current as E);
    }
  }

  void dispose();

  Future<void> notifyListeners(E event);

  void addListener(QueueEventListener<E> listener);

  void removeListener(QueueEventListener<E> listener);
}
