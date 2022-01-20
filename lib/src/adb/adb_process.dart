import 'package:fl_command/fl_command.dart';
import 'package:flutter/foundation.dart';
import 'package:process_run/shell.dart';

class AdbProcess extends FlProcess {
  AdbProcess(
      {ShellLinesController? shellController,
      TerminalController? terminalController,
      String? path,
      FlProcessOutput? onOutput})
      : super(
            shellController: shellController,
            onOutput: onOutput,
            terminalController: terminalController);

  bool get hasADB => whichSync('adb') != null;

  AdbScript adbScript = AdbScript();

  Future<List<String>?> install() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return null;
      case TargetPlatform.fuchsia:
        return null;
      case TargetPlatform.iOS:
        return null;
      case TargetPlatform.linux:
        break;
      case TargetPlatform.macOS:
        if (whichSync('brew') == null) return null;
        await runScript('brew ${adbScript.installADB}');
        break;
      case TargetPlatform.windows:
        break;
    }
    return currentOutput;
  }

  String removeSuffix(String string, String suffix) {
    if (!string.endsWith(suffix)) return string;
    return string.substring(0, string.length - suffix.length);
  }

  Future<List<String>> getDevices() async {
    await runScript(adbScript.devices);
    currentOutput.removeRange(0, 2);
    return currentOutput.map((e) => removeSuffix(e, 'device').trim()).toList();
  }

  Future<List<String>> getAndroidId({String? serial}) async {
    await runScript(adbScript.getAndroidId(serial: serial));
    return currentOutput;
  }

  Future<List<String>> wmSize({String? serial}) async {
    await runScript(adbScript.wmSize(serial: serial));
    return currentOutput;
  }

  Future<List<String>> startServer() async {
    await runScript(adbScript.startServer);
    return currentOutput;
  }

  Future<List<String>> killServer() async {
    await runScript(adbScript.killServer);
    return currentOutput;
  }
}
