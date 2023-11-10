import 'package:flutter_sqs/src/queue.dart';

class SingleListenerQueue<E> extends Queue<E> {
  QueueEventListener<E>? _listener;

  bool notifying = false;

  @override
  void addListener(QueueEventListener<E> listener) {
    _listener = listener;
  }

  @override
  void dispose() {
    _listener = null;
    notifying = false;
    super.dispose();
  }

  @override
  Future<void> notifyListeners(E event) async {
    notifying = true;

    await _listener?.call(event);

    notifying = false;

    next();
  }

  @override
  void removeListener(QueueEventListener<E> listener) {
    _listener = null;
    notifying = false;
  }
}
