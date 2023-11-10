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
    _assertNotifying('removeListener');
    _listener = null;
  }

  void _assertNotifying(String method) {
    assert(
      !notifying,
      'The "$method()" method on $this was called during the call to '
      '"notifyListeners()". This is likely to cause errors since it modifies '
      'the list of listeners while the list is being used.',
    );
  }
}
