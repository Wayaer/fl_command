import 'dart:async';

import 'package:fl_command/fl_command.dart';
import 'package:process_run/shell.dart';

class ScrcpyProcess extends FlProcess {
  ScrcpyProcess(
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

  bool get hasScrcpy => whichSync('scrcpy') != null;
  late ScrcpyScript scrcpyScript = ScrcpyScript();

  Future<bool> help([String? serial, bool autoADB = false]) async {
    await runScript(scrcpyScript.help);

    return false;
  }

  Future<bool> startScreen([String? serial, bool autoADB = false]) async {
    await runScript(scrcpyScript.start(serial, autoADB));
    return false;
  }

  Future<bool> setFullscreen() async {
    await runScript(scrcpyScript.setFullscreen);
    return false;
  }

  bool kill() => process?.kill() ?? false;
}
