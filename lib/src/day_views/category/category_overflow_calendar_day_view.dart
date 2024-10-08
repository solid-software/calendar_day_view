import 'dart:math';

import 'package:calendar_day_view/src/extensions/list_extensions.dart';
import 'package:calendar_day_view/src/extensions/time_of_day_extension.dart';
import 'package:calendar_day_view/src/widgets/timed_rebuilder.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:timezone/timezone.dart';

import '../../../calendar_day_view.dart';
import '../../utils/date_time_utils.dart';
import 'widgets/time_and_logo_widget.dart';

typedef TitleRowBuilder = Widget Function({
  required double rowHeight,
  required List<EventCategory> categories,
  required double tileWidth,
  required double timeColumnWidth,
  BoxDecoration? headerDecoration,
  VerticalDivider? verticalDivider,
  Widget? logo,
});

abstract class GroupingStrategy<T> {
  ({List<EventGroup<T>> grouped, List<CategorizedDayEvent<T>> nonGrouped})
      groupEvents(List<CategorizedDayEvent<T>> events);
}

class NoGroupingStrategy<T> implements GroupingStrategy<T> {
  const NoGroupingStrategy();
  @override
  ({List<EventGroup<T>> grouped, List<CategorizedDayEvent<T>> nonGrouped})
      groupEvents(List<CategorizedDayEvent<T>> events) {
    return (grouped: <EventGroup<T>>[], nonGrouped: events);
  }
}

class EventGroup<T> extends CategorizedDayEvent<T> {
  final List<CategorizedDayEvent<T>> events;

  EventGroup({
    required this.events,
    required super.categoryId,
    required super.start,
    required super.value,
    required super.end,
  });
}

abstract class GroupLayoutStrategy<T, U> {
  const GroupLayoutStrategy();
  bool canLayout(EventGroup<T> group) => true;

  Widget layout(
      BoxConstraints constraints,
      EventGroup<T> group,
      EventCategory<U> category,
      double heightPerMin,
      double tileWidth,
      CategoryDayViewEventBuilder<T> eventBuilder);
}

///CategoryOverflowCalendarDayView
///
/// where day view is divided into multiple category with fixed time slot.
/// events can be display overflowed into different time slot but within the same category column
class CategoryOverflowCalendarDayView<T, U> extends StatefulWidget
    implements CalendarDayView<T> {
  const CategoryOverflowCalendarDayView({
    Key? key,
    required this.categories,
    required this.events,
    this.startOfDay = const TimeOfDay(hour: 7, minute: 00),
    this.endOfDay = const TimeOfDay(hour: 17, minute: 00),
    required this.currentDate,
    this.timeGap = 60,
    this.heightPerMin = 1.0,
    this.evenRowColor,
    this.oddRowColor,
    this.verticalDivider,
    this.horizontalDivider,
    this.timeTextStyle,
    required this.eventBuilder,
    this.onTileTap,
    this.headerDecoration,
    this.timeColumnWidth = 50,
    this.backgroundTimeTileBuilder,
    this.titleRowBuilder,
    this.tableBodyBorder,
    this.timeColumnBorder,
    this.groupingStrategy,
    this.groupLayoutStrategy,
    required this.minColumnWidth,
    required this.timeLabelsFormatter,
    required this.currentTimeFormatter,
    ValueGetter<DateTime>? clock,
  })  : clock = clock ?? DateTime.now,
        super(key: key);

  final Border? tableBodyBorder;
  final Border? timeColumnBorder;
  final double minColumnWidth;
  final ValueGetter<DateTime> clock;
  final GroupingStrategy<T>? groupingStrategy;
  final GroupLayoutStrategy<T, U>? groupLayoutStrategy;

  final TitleRowBuilder? titleRowBuilder;

  final TimeFormatter timeLabelsFormatter;

  final TimeFormatter currentTimeFormatter;

  /// List of category
  final List<EventCategory<U>> categories;

  /// List of events
  final List<CategorizedDayEvent<T>> events;

  /// width of the first column where times are displayed
  final double timeColumnWidth;

  /// the date that this dayView is presenting
  final TZDateTime currentDate;

  /// To set the start time of the day view
  final TimeOfDay startOfDay;

  /// To set the end time of the day view
  final TimeOfDay endOfDay;

  /// time gap/duration of a row.
  ///
  /// This will determine the minimum height of a row
  /// row height is calculated by `rowHeight = heightPerMin * timeGap`
  final int timeGap;

  /// height in pixel per minute
  final double heightPerMin;

  /// background color of the even-indexed row
  final Color? evenRowColor;

  /// background color of the odd-indexed row
  final Color? oddRowColor;

  /// dividers that run vertically in the day view
  final VerticalDivider? verticalDivider;

  /// dividers that run horizontally in the day view
  final Divider? horizontalDivider;

  /// time label text style
  final TextStyle? timeTextStyle;

  /// event builder
  final CategoryDayViewEventBuilder<T> eventBuilder;

  /// call when you tap on an empty tile
  ///
  /// provide [EventCategory] and [DateTime]  of that tile
  final CategoryDayViewTileTap? onTileTap;

  /// Allow user to customize the UI of each time slot in the background.
  final CategoryBackgroundTimeTileBuilder? backgroundTimeTileBuilder;

  /// build category header
  // final CategoryDayViewHeaderTileBuilder? headerTileBuilder;

  /// header row decoration
  final BoxDecoration? headerDecoration;

  @override
  State<CategoryOverflowCalendarDayView<T, U>> createState() =>
      _CategoryOverflowCalendarDayViewState<T, U>();
}

class _CategoryOverflowCalendarDayViewState<T, U>
    extends State<CategoryOverflowCalendarDayView<T, U>> {
  final _horizontalScrollLink = LinkedScrollControllerGroup();
  late final _headerScrollController = _horizontalScrollLink.addAndGet();
  late final _horizScrollController = _horizontalScrollLink.addAndGet();
  final _verticalScrollLink = LinkedScrollControllerGroup();
  late final _timeScrollController = _verticalScrollLink.addAndGet();
  late final _vertScrollController = _verticalScrollLink.addAndGet();

  @override
  Widget build(BuildContext context) {
    final timeStart = widget.currentDate.copyTimeAndMinClean(widget.startOfDay);
    final timeEnd = widget.currentDate.copyTimeAndMinClean(widget.endOfDay);

    final timeList = getTimeList(
      timeStart,
      timeEnd,
      widget.timeGap,
    );

    final rowHeight = widget.heightPerMin * widget.timeGap;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final categoriesCount = widget.categories.length;
          final minTileWidth = widget.minColumnWidth;
          final minTotalWidth = minTileWidth * categoriesCount;

          final totalWidth = max(minTotalWidth, constraints.maxWidth);
          final rowLength = totalWidth - widget.timeColumnWidth;
          final tileWidth = rowLength / categoriesCount;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: totalWidth,
                child: SingleChildScrollView(
                  controller: _headerScrollController,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: widget.titleRowBuilder!.call(
                    rowHeight: rowHeight,
                    verticalDivider: widget.verticalDivider,
                    categories: widget.categories,
                    tileWidth: tileWidth,
                    headerDecoration: widget.headerDecoration,
                    timeColumnWidth: widget.timeColumnWidth,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    ClipPath(
                      clipper: VerticalClipper(),
                      child: DecoratedBox(
                        decoration:
                            BoxDecoration(border: widget.timeColumnBorder),
                        child: SizedBox(
                          width: widget.timeColumnWidth,
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            controller: _timeScrollController,
                            clipBehavior: Clip.none,
                            child: TimeColumn(
                              rowHeight: rowHeight,
                              timeColumnWidth: widget.timeColumnWidth,
                              timeList: timeList,
                              evenRowColor: widget.evenRowColor,
                              oddRowColor: widget.oddRowColor,
                              headerDecoration: widget.headerDecoration,
                              horizontalDivider: widget.horizontalDivider,
                              verticalDivider: widget.verticalDivider,
                              timeTextStyle: widget.timeTextStyle,
                              heightPerMin: widget.heightPerMin,
                              clock: widget.clock,
                              timeFormatter: widget.timeLabelsFormatter,
                              currentTimeFormatter: widget.currentTimeFormatter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipPath(
                        clipper: VerticalClipper(),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              border: widget.tableBodyBorder,
                              color: Colors.black),
                          child: SingleChildScrollView(
                            controller: _vertScrollController,
                            clipBehavior: Clip.none,
                            physics: const ClampingScrollPhysics(),
                            child: SingleChildScrollView(
                              controller: _horizScrollController,
                              clipBehavior: Clip.none,
                              physics: const ClampingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: rowLength,
                                child: _DayViewBody<T, U>(
                                  timeList: timeList,
                                  rowHeight: rowHeight,
                                  tileWidth: tileWidth,
                                  evenRowColor: widget.evenRowColor,
                                  oddRowColor: widget.oddRowColor,
                                  rowBuilder: widget.backgroundTimeTileBuilder,
                                  events: widget.events,
                                  categories: widget.categories,
                                  verticalDivider: widget.verticalDivider,
                                  timeGap: widget.timeGap,
                                  heightPerMin: widget.heightPerMin,
                                  timeTextStyle: widget.timeTextStyle,
                                  eventBuilder: widget.eventBuilder,
                                  horizontalDivider: widget.horizontalDivider,
                                  onTileTap: widget.onTileTap,
                                  groupingStrategy: widget.groupingStrategy ??
                                      NoGroupingStrategy<T>(),
                                  groupLayoutStrategy:
                                      widget.groupLayoutStrategy,
                                  clock: widget.clock,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class VerticalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..addRect(Rect.fromLTRB(0, 0, size.width, size.height + 200));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _DayViewBody<T, U> extends StatelessWidget {
  const _DayViewBody({
    required this.timeList,
    required this.rowHeight,
    required this.tileWidth,
    required this.events,
    required this.timeGap,
    required this.heightPerMin,
    required this.eventBuilder,
    required this.categories,
    required this.clock,
    this.groupingStrategy = const NoGroupingStrategy(),
    this.groupLayoutStrategy,
    this.evenRowColor,
    this.oddRowColor,
    this.rowBuilder,
    this.timeTextStyle,
    this.verticalDivider,
    this.horizontalDivider,
    this.onTileTap,
    super.key,
  });

  final List<DateTime> timeList;
  final double rowHeight;
  final double tileWidth;
  final Color? evenRowColor;
  final Color? oddRowColor;
  final CategoryBackgroundTimeTileBuilder? rowBuilder;
  final List<CategorizedDayEvent<T>> events;
  final int timeGap;
  final double heightPerMin;
  final TextStyle? timeTextStyle;
  final VerticalDivider? verticalDivider;
  final Divider? horizontalDivider;
  final CategoryDayViewEventBuilder<T> eventBuilder;
  final List<EventCategory<U>> categories;
  final CategoryDayViewTileTap? onTileTap;
  final GroupingStrategy<T> groupingStrategy;
  final GroupLayoutStrategy<T, U>? groupLayoutStrategy;
  final ValueGetter<DateTime> clock;

  @override
  Widget build(BuildContext context) {
    final (:grouped, :nonGrouped) = groupingStrategy.groupEvents(events);

    return SizedBox(
      height: rowHeight * timeList.length,
      width: tileWidth * categories.length,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _TableBackground(
            horizontalDivider: horizontalDivider,
            timeList: timeList,
            rowHeight: rowHeight,
            categories: categories,
            tileWidth: tileWidth,
            rowBuilder: rowBuilder,
            verticalDivider: verticalDivider,
            clock: clock,
          ),
          for (final event in nonGrouped)
            Builder(
              builder: (context) {
                final (category, cateIndex) = categories
                    .firstWhereIndexed((c) => c.id == event.categoryId);

                final constraints = BoxConstraints(
                  maxHeight: event.durationInMins.toDouble() * heightPerMin,
                  maxWidth: tileWidth,
                );

                return Positioned(
                  top: event.minutesFrom(timeList.first) * heightPerMin,
                  left: cateIndex * tileWidth,
                  child: eventBuilder(
                    constraints,
                    category,
                    event.start,
                    event,
                  ),
                );
              },
            ),
          for (final group in grouped)
            Builder(
              builder: (context) {
                final (category, cateIndex) = categories
                    .firstWhereIndexed((c) => c.id == group.categoryId);

                final constraints = BoxConstraints(
                  maxHeight: group.durationInMins.toDouble() * heightPerMin,
                  maxWidth: tileWidth,
                );

                return Positioned(
                  top: group.minutesFrom(timeList.first) * heightPerMin,
                  left: cateIndex * tileWidth,
                  child: groupLayoutStrategy!.layout(
                    constraints,
                    group,
                    category,
                    heightPerMin,
                    tileWidth,
                    eventBuilder,
                  ),
                );
              },
            ),
          TimedRebuilder(
            rebuildInterval: const Duration(seconds: 1),
            builder: (context) {
              final now = clock();

              return Positioned(
                top: now.difference(timeList.first).inMinutes * heightPerMin,
                child: Container(
                  height: 1,
                  constraints:
                      BoxConstraints(minWidth: tileWidth * categories.length),
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TableBackground extends StatelessWidget {
  const _TableBackground({
    required this.horizontalDivider,
    required this.timeList,
    required this.rowHeight,
    required this.categories,
    required this.tileWidth,
    required this.rowBuilder,
    required this.verticalDivider,
    required this.clock,
  });

  final Divider? horizontalDivider;
  final List<DateTime> timeList;
  final double rowHeight;
  final List<EventCategory> categories;
  final double tileWidth;
  final CategoryBackgroundTimeTileBuilder? rowBuilder;
  final VerticalDivider? verticalDivider;
  final ValueGetter<DateTime> clock;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) =>
          horizontalDivider ?? const Divider(height: 0),
      clipBehavior: Clip.none,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: timeList.length,
      itemBuilder: (context, index) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: rowHeight),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...categories.map(
                (c) => [
                  SizedBox(
                    height: rowHeight,
                    width: tileWidth,
                    child: rowBuilder?.call(
                          context,
                          BoxConstraints(
                            maxHeight: rowHeight,
                            maxWidth: tileWidth,
                          ),
                          clock(),
                          c,
                          index % 2 != 0,
                        ) ??
                        const SizedBox.shrink(),
                  ),
                  verticalDivider ?? const VerticalDivider(width: 0),
                ],
              )
            ].expand((element) => element).toList(),
          ),
        );
      },
    );
  }
}
