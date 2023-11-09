class QueueItem<T> {
  final T value;
  final int priority;
  final String? key;

  QueueItem({
    required this.value,
    int? priority,
    this.key,
  }) : priority = priority ?? DateTime.now().millisecondsSinceEpoch;
}
