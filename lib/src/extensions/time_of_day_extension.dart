import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

extension DateTimeExtension on TZDateTime {
  bool earlierThan(TZDateTime other) {
    return isBefore(other);
    // return hour < other.hour || ((hour == other.hour) && minute < other.minute);
  }

  bool laterThan(TZDateTime other) {
    return isAfter(other);
    // return hour > other.hour || ((hour == other.hour) && minute > other.minute);
  }

  bool same(DateTime other) => hour == other.hour && minute == other.minute;

  int minuteFrom(TZDateTime timePoint) {
    return (hour - timePoint.hour) * 60 + (minute - timePoint.minute);
  }

  int minuteUntil(TZDateTime timePoint) {
    return timePoint.cleanSec().difference(cleanSec()).inMinutes;
    // return (timePoint.hour - hour) * 60 + (timePoint.minute - minute);
  }

  bool inTheGap(DateTime timePoint, int gap) {
    return hour == timePoint.hour &&
        (minute >= timePoint.minute && minute < (timePoint.minute + gap));
  }

  TZDateTime copyTimeAndMinClean(TimeOfDay tod) => copyWithPreservingLocation(
        hour: tod.hour,
        minute: tod.minute,
        second: 00,
        millisecond: 0,
        microsecond: 0,
      );

  TZDateTime cleanSec() =>
      copyWithPreservingLocation(second: 00, millisecond: 0, microsecond: 0);

  TZDateTime copyWithPreservingLocation({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
    bool? isUtc,
  }) {
    return TZDateTime(
      location,
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}
