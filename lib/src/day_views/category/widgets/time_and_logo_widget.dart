import 'package:calendar_day_view/src/widgets/timed_rebuilder.dart';
import 'package:flutter/material.dart';

typedef TimeFormatter = String Function(DateTime);

class TimeColumn extends StatelessWidget {
  const TimeColumn({
    super.key,
    required this.rowHeight,
    required this.timeColumnWidth,
    this.logo,
    this.headerDecoration,
    this.verticalDivider,
    this.horizontalDivider,
    required this.timeList,
    required this.evenRowColor,
    required this.oddRowColor,
    this.timeTextStyle,
    required this.heightPerMin,
    required this.clock,
    required this.timeFormatter,
    required this.currentTimeFormatter,
  });

  final double rowHeight;
  final double timeColumnWidth;
  final Widget? logo;
  final BoxDecoration? headerDecoration;
  final VerticalDivider? verticalDivider;
  final Divider? horizontalDivider;
  final List<DateTime> timeList;
  final Color? evenRowColor;
  final Color? oddRowColor;
  final TextStyle? timeTextStyle;
  final double heightPerMin;
  final ValueGetter<DateTime> clock;
  final TimeFormatter timeFormatter;
  final TimeFormatter currentTimeFormatter;

  @override
  Widget build(BuildContext context) {
    final textStyle = timeTextStyle ?? Theme.of(context).textTheme.bodySmall;
    final timeStagger = textStyle!.fontSize! ~/ 2;

    return Stack(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: timeList.length,
          itemBuilder: (context, index) {
            final time = timeList.elementAt(index);

            BoxConstraints constraints =
                BoxConstraints.tightFor(height: rowHeight);
            if (index == 0) {
              constraints =
                  BoxConstraints.tightFor(height: rowHeight - timeStagger);
            }
            if (index == timeList.length - 1) {
              constraints =
                  BoxConstraints.tightFor(height: rowHeight + timeStagger);
            }

            return ConstrainedBox(
              constraints: constraints,
              key: ValueKey(time),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? evenRowColor : oddRowColor,
                    ),
                    constraints: constraints,
                    child: SizedBox(
                      width: timeColumnWidth,
                      child: Text(
                        timeFormatter(time),
                        style: textStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        TimedRebuilder(
          rebuildInterval: const Duration(seconds: 1),
          builder: (context) {
            final now = clock();
            return Positioned(
              top: now.difference(timeList.first).inMinutes * heightPerMin - 8,
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                constraints: BoxConstraints(minWidth: timeColumnWidth),
                child: Center(
                  child: Text(
                    currentTimeFormatter(now),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
