import 'package:fl_command/fl_command.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';

class FlADB extends StatefulWidget {
  const FlADB({super.key});

  @override
  State<FlADB> createState() => _FlADBState();
}

class _FlADBState extends State<FlADB> {
  late AdbProcess adbProcess = AdbProcess();

  List<String> devices = [];
  String? currentSerial;

  @override
  void initState() {
    super.initState();
    adbProcess.getDevices().then((value) async {
      final res = await adbProcess.pressInputKeyEvent(
          value.first.id, InputKeyEvent.menu);
      print("===");
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Universal(
        height: double.infinity, direction: Axis.horizontal, children: []);
  }

  List<Widget> get adbWidget => [
        if (devices.isNotEmpty)
          DropdownMenuButton(
              itemBuilder: (int index) {
                return Text(devices[index]);
              },
              itemCount: devices.length,
              onChanged: (int index) {
                currentSerial = devices[index];
              },
              builder: (int? index) {
                return Text(index == null ? '未选择设备' : devices[index]);
              })
        else
          const Text('请先调用 \n adb devices'),
        if (devices.isNotEmpty) ...control
      ];

  List<Widget> get control => [];
}
