import 'package:equatable/equatable.dart';

class QueueItem<T> extends Equatable {
  final T value;
  final int priority;
  final String? key;

  QueueItem({
    required this.value,
    int? priority,
    this.key,
  }) : priority = priority ?? DateTime.now().microsecondsSinceEpoch;

  @override
  List<Object?> get props => [
        priority,
        key,
      ];
}
