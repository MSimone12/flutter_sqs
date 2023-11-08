class QueueItem<T> {
  final T value;
  final int priority;

  QueueItem({
    required this.value,
    int? priority,
  }) : priority = priority ?? double.maxFinite.toInt();
}
