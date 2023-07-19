import 'package:flutter_sqs/src/queue.dart';

class BroadcastQueue<E> extends Queue<E> {
  static final List<QueueEventListener?> _emptyListeners =
      List<QueueEventListener?>.filled(0, null);
  List<QueueEventListener<E>?> _listeners = _emptyListeners;
  int _count = 0;
  int _notificationCallStackDepth = 0;
  int _reentrantlyRemovedListeners = 0;

  @override
  void addListener(QueueEventListener<E> listener) {
    if (_count == _listeners.length) {
      if (_count == 0) {
        _listeners = List<QueueEventListener<E>?>.filled(1, null);
      } else {
        final List<QueueEventListener<E>?> newListeners =
            List<QueueEventListener<E>?>.filled(_listeners.length * 2, null);
        for (int i = 0; i < _count; i++) {
          newListeners[i] = _listeners[i];
        }
        _listeners = newListeners;
      }
    }
    _listeners[_count++] = listener;
  }

  @override
  void dispose() {
    assert(
      _notificationCallStackDepth == 0,
      'The "dispose()" method on $this was called during the call to '
      '"notifyListeners()". This is likely to cause errors since it modifies '
      'the list of listeners while the list is being used.',
    );
    _listeners = _emptyListeners;
    _count = 0;
  }

  @override
  void removeListener(QueueEventListener<E> listener) {
    for (int i = 0; i < _count; i++) {
      final QueueEventListener<E>? listenerAtIndex = _listeners[i];
      if (listenerAtIndex == listener) {
        if (_notificationCallStackDepth > 0) {
          _listeners[i] = null;
          _reentrantlyRemovedListeners++;
        } else {
          _removeAt(i);
        }
        break;
      }
    }
  }

  void _removeAt(int index) {
    _count -= 1;
    if (_count * 2 <= _listeners.length) {
      final List<QueueEventListener<E>?> newListeners =
          List<QueueEventListener<E>?>.filled(_count, null);

      for (int i = 0; i < index; i++) {
        newListeners[i] = _listeners[i];
      }

      for (int i = index; i < _count; i++) {
        newListeners[i] = _listeners[i + 1];
      }

      _listeners = newListeners;
    } else {
      for (int i = index; i < _count; i++) {
        _listeners[i] = _listeners[i + 1];
      }
      _listeners[_count] = null;
    }
  }

  @override
  Future<void> notifyListeners(E event) async {
    if (_count == 0) {
      return;
    }
    _notificationCallStackDepth++;

    final int end = _count;
    final futures = <Future<void>>[];
    for (int i = 0; i < end; i++) {
      if (_listeners[i] != null) {
        futures.add(_listeners[i]!.call(event));
      }
    }
    await Future.wait(futures);

    _notificationCallStackDepth--;

    if (_notificationCallStackDepth == 0 && _reentrantlyRemovedListeners > 0) {
      final int newLength = _count - _reentrantlyRemovedListeners;
      if (newLength * 2 <= _listeners.length) {
        final List<QueueEventListener<E>?> newListeners =
            List<QueueEventListener<E>?>.filled(newLength, null);

        int newIndex = 0;
        for (int i = 0; i < _count; i++) {
          final QueueEventListener<E>? listener = _listeners[i];
          if (listener != null) {
            newListeners[newIndex++] = listener;
          }
        }

        _listeners = newListeners;
      } else {
        for (int i = 0; i < newLength; i += 1) {
          if (_listeners[i] == null) {
            int swapIndex = i + 1;
            while (_listeners[swapIndex] == null) {
              swapIndex += 1;
            }
            _listeners[i] = _listeners[swapIndex];
            _listeners[swapIndex] = null;
          }
        }
      }

      _reentrantlyRemovedListeners = 0;
      _count = newLength;
    }

    next();
  }
}
