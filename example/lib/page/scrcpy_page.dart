import 'package:example/main.dart';
import 'package:fl_command/fl_command.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';

class FlScrcpy extends StatefulWidget {
  const FlScrcpy({Key? key}) : super(key: key);

  @override
  State<FlScrcpy> createState() => _FlScrcpyState();
}

class _FlScrcpyState extends State<FlScrcpy> {
  late ScrcpyProcess scrcpyProcess;
  late AdbProcess adbProcess;

  TerminalController controller = TerminalController();

  @override
  void initState() {
    super.initState();
    scrcpyProcess = ScrcpyProcess(terminalController: controller);
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
              children: scrcpyProcess.hasScrcpy
                  ? scrcpy
                  : [
                      Button('Install\nscrcpy', onTap: () {}),
                    ]),
          const SizedBox(width: 10),
          Expanded(flex: 3, child: TerminalView(controller: controller)),
        ]);
  }

  List<Widget> get scrcpy => [
        Button('scrcpy help', onTap: () {
          scrcpyProcess.help();
        }),
        if (adbProcess.hasADB) ...[
          Button('adb devices', onTap: () {
            adbProcess.getDevices();
          }),
          Button('start screen', onTap: () async {
            scrcpyProcess.kill();
            scrcpyProcess.startScreen();
          }),
          Button('full screen', onTap: () async {
            scrcpyProcess.kill();
            scrcpyProcess.setFullscreen();
          }),
          Button('kill', onTap: () {
            scrcpyProcess.kill();
          }),
        ]
      ];
}
