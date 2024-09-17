import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;

  const CountdownTimer({Key? key, required this.endTime}) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.endTime.difference(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), _updateRemainingTime);
  }

  void _updateRemainingTime(Timer timer) {
    final now = DateTime.now();
    final newRemainingTime = widget.endTime.difference(now);
    if (newRemainingTime.isNegative) {
      _timer.cancel();
      setState(() {
        _remainingTime = Duration.zero;
      });
    } else {
      setState(() {
        _remainingTime = newRemainingTime;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours % 24;
    final minutes = _remainingTime.inMinutes % 60;
    final seconds = _remainingTime.inSeconds % 60;

    return Text(
      '$days日 $hours時間 $minutes分 $seconds秒',
      style: TextStyle(fontSize: 18.0),
    );
  }
}
