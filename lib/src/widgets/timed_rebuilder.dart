import 'dart:async';

import 'package:flutter/material.dart';

class TimedRebuilder extends StatefulWidget {
  final WidgetBuilder builder;
  final Duration rebuildInterval;
  const TimedRebuilder({
    super.key,
    required this.builder,
    required this.rebuildInterval,
  });

  @override
  State<TimedRebuilder> createState() => _TimedRebuilderState();
}

class _TimedRebuilderState extends State<TimedRebuilder> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(widget.rebuildInterval, (_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
