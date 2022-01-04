import 'package:example/main.dart';
import 'package:fl_command/fl_command.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FlScrcpy extends StatefulWidget {
  const FlScrcpy({Key? key, this.height = 200}) : super(key: key);
  final double height;

  @override
  _FlScrcpyState createState() => _FlScrcpyState();
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
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {});
    setDesktopSize(const Size(600, 600));
  }

  @override
  Widget build(BuildContext context) {
    if (supportedPlatforms) {
      return SizedBox(
          height: widget.height,
          child: Row(children: [
            Expanded(
                flex: 1,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: scrcpyProcess.hasScrcpy
                        ? [
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
                          ]
                        : [
                            Button('Install\nscrcpy', onTap: () {}),
                          ])),
            const SizedBox(width: 10),
            Expanded(flex: 3, child: TerminalView(controller: controller)),
          ]));
    }
    return const Center(child: Text('The platform is not supported'));
  }

  bool get supportedPlatforms =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows);

  @override
  void dispose() {
    super.dispose();
    setDesktopSize(const Size(300, 300));
  }
}
