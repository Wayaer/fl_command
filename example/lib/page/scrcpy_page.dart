import 'package:fl_command/fl_command.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';

class FlScrcpy extends StatefulWidget {
  const FlScrcpy({super.key});

  @override
  State<FlScrcpy> createState() => _FlScrcpyState();
}

class _FlScrcpyState extends State<FlScrcpy> {
  late AdbProcess adbProcess;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Universal(
        height: double.infinity,
        direction: Axis.horizontal,
        children: [
          SizedBox(width: 10),
        ]);
  }

  List<Widget> get scrcpy => [];
}
