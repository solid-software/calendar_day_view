import 'package:timezone/timezone.dart';

class DayEvent<T> {
  final T value;
  final TZDateTime start;
  final TZDateTime end;
  final String? name;

  DayEvent({
    required this.value,
    required this.start,
    required this.end,
    this.name,
  }) : assert(
          end.isAfter(start),
          "End can not be before start| start: $start |end: $end ",
        );

  DayEvent<T> copyWith({
    T? value,
    TZDateTime? start,
    TZDateTime? end,
    String? name,
  }) {
    return DayEvent<T>(
      value: value ?? this.value,
      start: start ?? this.start,
      end: end ?? this.end,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return 'DayEvent(value: $value, start: $start, end: $end, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DayEvent<T> &&
        other.value == value &&
        other.start == start &&
        other.end == end &&
        other.name == name;
  }

  @override
  int get hashCode {
    return value.hashCode ^ start.hashCode ^ end.hashCode ^ name.hashCode;
  }
}

extension DayEventExtension on DayEvent {
  int get durationInMins => end.difference(start).inMinutes;

  int get timeGapFromZero => start.hour * 60 + start.minute;

  int minutesFrom(DateTime timePoint) => start.difference(timePoint).inMinutes;
  // (start.hour - timePoint.hour) * 60 + (start.minute - timePoint.minute);

  bool isInThisGap(DateTime timePoint, int gap) {
    final dif = start
        .copyWith(second: 00)
        .difference(timePoint.copyWith(second: 00))
        .inSeconds;
    return dif <= gap && dif >= 0;
    // return start.hour == timePoint.hour &&
    //     (start.minute >= timePoint.minute &&
    //         start.minute < (timePoint.minute + gap));
  }

  bool startInThisGap(DateTime timePoint, int gap) {
    return start.isAfter(timePoint) &&
        start.isBefore(timePoint.add(Duration(minutes: gap)));
  }

  bool startAt(DateTime timePoint) =>
      start.hour == timePoint.hour && timePoint.minute == start.minute;

  int compare(DayEvent other) {
    return start.isBefore(other.start) ? -1 : 1;

    // if (start.hour > other.start.hour) return 1;
    // if (start.hour == other.start.hour && start.minute > other.start.minute) {
    //   return 1;
    // }
    // return -1;
  }
}
