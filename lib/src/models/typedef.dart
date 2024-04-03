import 'package:flutter/material.dart';

import '../../calendar_day_view.dart';

typedef DayViewItemBuilder<T> = Widget Function(
  BuildContext context,
  BoxConstraints constraints,

  ///index of the item in same row
  int itemIndex,
  DayEvent<T> event,
);

typedef DayViewTimeRowBuilder<T> = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
  List<DayEvent<T>> events,
);

typedef EventDayViewItemBuilder<T> = Widget Function(
  BuildContext context,
  int itemIndex,
  DayEvent<T> event,
);

typedef CategoryBackgroundTimeRowBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
  DateTime rowTime,
  bool isOdd,
);
typedef CategoryBackgroundTimeTileBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
  DateTime rowTime,
  EventCategory category,
  bool isOddRow,
);

typedef OnTimeTap = Function(DateTime time);

typedef CategoryDayViewEventBuilder<T> = Widget Function(
  BoxConstraints constraints,
  EventCategory category,
  DateTime time,
  CategorizedDayEvent<T> event,
);
typedef CategoryDayViewRowBuilder<T> = Widget Function(
  List<EventCategory> category,
  List<CategorizedDayEvent<T>> events,
  DateTime time,
);
typedef CategoryDayViewTileTap<T> = Function(
  EventCategory category,
  DateTime time,
);

/// To build the controller bar on the top of the day view
///
/// [goToPreviousTab] to animate to previous tabs
/// [goToNextTab] to animate to next tabs
typedef CategoryDayViewControlBarBuilder = Widget Function(
  void Function() goToPreviousTab,
  void Function() goToNextTab,
);

typedef CategoryDayViewHeaderTileBuilder = Function(
  BoxConstraints constraints,
  EventCategory category,
);
