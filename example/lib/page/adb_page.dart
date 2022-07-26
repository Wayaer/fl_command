import 'package:example/main.dart';
import 'package:fl_command/fl_command.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';

class FlADB extends StatefulWidget {
  const FlADB({Key? key}) : super(key: key);

  @override
  State<FlADB> createState() => _FlADBState();
}

class _FlADBState extends State<FlADB> {
  late AdbProcess adbProcess;
  TerminalController controller = TerminalController();

  List<String> devices = [];
  String? currentSerial;

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
              margin: const EdgeInsets.only(top: 50, bottom: 20),
              children: adbProcess.hasADB
                  ? adbWidget
                  : [
                      Button('install adb', onTap: () {
                        adbProcess.install();
                      }),
                    ]),
          Expanded(flex: 3, child: TerminalView(controller: controller)),
        ]);
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
              defaultBuilder: (int? index) {
                return Text(index == null ? '未选择设备' : devices[index]);
              })
        else
          const Text('请先调用 \n adb devices'),
        Button('adb devices', onTap: () async {
          devices = await adbProcess.getDevices();
          setState(() {});
        }),
        Button('start server', onTap: () async {
          var value = await adbProcess.startServer();
          log(value);
        }),
        Button('kill server', onTap: () async {
          var value = await adbProcess.killServer();
          log(value);
        }),
        if (devices.isNotEmpty) ...control
      ];

  List<Widget> get control => [
        Button('getAndroidId', onTap: () async {
          var value = await adbProcess.getAndroidId(serial: currentSerial);
          log(value);
        }),
        Button('wm size', onTap: () async {
          var value = await adbProcess.wmSize(serial: currentSerial);
          log(value);
        }),
      ];
}
