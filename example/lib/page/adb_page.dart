import 'package:example/main.dart';
import 'package:fl_command/fl_command.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';

class FlADB extends StatefulWidget {
  const FlADB({Key? key}) : super(key: key);

  @override
  _FlADBState createState() => _FlADBState();
}

class _FlADBState extends State<FlADB> {
  late AdbProcess adbProcess;
  TerminalController controller = TerminalController();

  @override
  void initState() {
    super.initState();
    adbProcess = AdbProcess(terminalController: controller);
  }

  @override
  Widget build(BuildContext context) {
    return Universal(
        height: double.infinity,
        direction: Axis.horizontal,
        children: [
          Universal(
              flex: 1,
              expanded: true,
              isScroll: true,
              height: double.infinity,
              margin: const EdgeInsets.only(top: 45, bottom: 20),
              children: adbProcess.hasADB
                  ? adbWidget
                  : [
                      Button('install adb', onTap: () {}),
                    ]),
          Expanded(flex: 3, child: TerminalView(controller: controller)),
        ]);
  }

  List<Widget> get adbWidget => [
        Button('adb devices', onTap: () {
          adbProcess.getDevices();
        }),
        Button('start server', onTap: () {
          adbProcess.startServer();
        }),
        Button('kill server', onTap: () {
          adbProcess.killServer();
        }),
      ];
}
