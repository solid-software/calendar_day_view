import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart';

import 'day_event.dart';

class OverflowEventsRow<T> {
  final List<DayEvent<T>> events;
  final TZDateTime start;
  final TZDateTime end;
  OverflowEventsRow({
    required this.events,
    required this.start,
    required this.end,
  });

  OverflowEventsRow<T> copyWith({
    List<DayEvent<T>>? events,
    TZDateTime? start,
    TZDateTime? end,
  }) {
    return OverflowEventsRow<T>(
      events: events ?? this.events,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  String toString() =>
      'OverflowEventsRow(events: $events, start: $start, end: $end)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OverflowEventsRow<T> &&
        listEquals(other.events, events) &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => events.hashCode ^ start.hashCode ^ end.hashCode;
}
