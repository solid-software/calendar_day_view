import 'package:timezone/timezone.dart';

List<TZDateTime> getTimeList(TZDateTime start, TZDateTime end, int timeGap) {
  final duration = end.difference(start).inMinutes;

  final timeCount = duration ~/ timeGap;

  var tempTime = start;
  List<TZDateTime> list = [];
  for (var i = 0; i < timeCount; i++) {
    list.add(tempTime);
    tempTime = tempTime.add(Duration(minutes: timeGap));
  }
  return list;
}
