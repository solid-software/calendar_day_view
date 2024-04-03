import 'package:calendar_day_view/src/widgets/timed_rebuilder.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: timeList.length,
          itemBuilder: (context, index) {
            final time = timeList.elementAt(index);

            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: rowHeight),
              key: ValueKey(time),
              child: Row(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? evenRowColor : oddRowColor,
                      ),
                      constraints: BoxConstraints(
                        maxHeight: rowHeight,
                        minHeight: rowHeight,
                      ),
                      child: SizedBox(
                        width: timeColumnWidth - 1,
                        child: Center(
                          child: Text(
                            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, "0")}",
                            style: timeTextStyle,
                          ),
                        ),
                      )),
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
                    '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
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
