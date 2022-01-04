import 'package:fl_command/fl_command.dart';
import 'package:process_run/shell.dart';

class AdbProcess extends FlProcess {
  AdbProcess(
      {Shell? shell,
        ShellLinesController? shellController,
        TerminalController? terminalController,
        String? path,
        FlProcessOutput? onOutput})
      : super(
      shell: shell,
      shellController: shellController,
      onOutput: onOutput,
      terminalController: terminalController);

  bool get hasADB => whichSync('adb') != null;
  AdbScript adbScript = AdbScript();

  Future<bool> getDevices() async {
    await runScript(adbScript.devices);
    return false;
  }

  Future<bool> startServer() async {
    await runScript(adbScript.startServer);
    return false;
  }

  Future<bool> killServer() async {
    await runScript(adbScript.killServer);
    return false;
  }
}
