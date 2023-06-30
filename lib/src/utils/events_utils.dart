import '../../calendar_day_view.dart';
import '../extensions/time_of_day_extension.dart';
import '../models/overflow_event.dart';

/// From List of DayEvent process them into multiple OverflowEventRow
///
/// where each row contains multiple DayEvent that happen overlap each other
/// in the time range of a row.

List<OverflowEventsRow<T>> processOverflowEvents<T extends Object>(
  List<DayEvent<T>> sortedEvents, {
  required DateTime startOfDay,
  required DateTime endOfDay,
}) {
  if (sortedEvents.isEmpty) return [];

  var start = sortedEvents.first.start.cleanSec();
  var end = sortedEvents.first.end!;

  final Map<DateTime, OverflowEventsRow<T>> oM = {};

  for (var event in sortedEvents) {
    if (event.start.isBefore(startOfDay) || event.start.isAfter(endOfDay)) {
      continue;
    }
    // if (event.end!.isAfter(endOfDay)) {
    //   event = event.copyWith(end: endOfDay);
    // }

    if (event.start.earlierThan(end)) {
      oM.update(
        start,
        (value) => value.copyWith(events: [...value.events, event]),
        ifAbsent: () => OverflowEventsRow(
            events: [event], start: event.start, end: event.end!),
      );

      if (event.end!.laterThan(end)) {
        end = event.end!.isBefore(endOfDay) ? event.end! : endOfDay;
        oM[start] = oM[start]!.copyWith(end: event.end!);
      }
    } else {
      start = event.start.cleanSec();
      end = event.end!;
      oM[start] = OverflowEventsRow(
          events: [event], start: event.start, end: event.end!);
    }
  }

  return oM.values.toList();
}
