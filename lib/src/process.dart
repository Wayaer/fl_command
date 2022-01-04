import 'dart:async';
import 'dart:io';

import 'package:fl_command/fl_command.dart';
import 'package:flutter/cupertino.dart';
import 'package:process_run/shell.dart';
typedef FlProcessOutput= void Function(String event);

class FlProcess with ChangeNotifier {
  FlProcess(
      {Shell? shell,
      ShellLinesController? shellController,
      this.terminalController,
      String? path,
      this.onOutput}) {
    this.shellController = shellController ?? ShellLinesController();
    this.shell = shell ??
        Shell(
            stdout: this.shellController.sink,
            workingDirectory: path,
            verbose: true,
            commentVerbose: true,
            commandVerbose: true);
    _listen = this.shellController.stream.listen(_outListen);
  }

  void _outListen(event) {
    onOutput?.call(event);
    terminalController?.output(event);
  }

  /// 当前 run 的 进程
  Process? process;

  /// 命令输入控制器
  late TerminalController? terminalController;

  /// shell 控制器
  late ShellLinesController shellController;

  /// shell
  late Shell shell;

  /// 输入内容回调
  final FlProcessOutput? onOutput;

  /// 输入内容监听
  StreamSubscription<dynamic>? _listen;

  Future<List<ProcessResult>> runScript(String script) async {
    terminalController?.run(script);
    return await shell.run(script, onProcess: (Process p) {
      process = p;
    }).onError((error, stackTrace) {
      terminalController?.exception(error.toString());
      return Future.error(error!);
    });
  }

  @override
  void dispose() {
    _listen?.cancel();
    process?.kill();
    shellController.close();
    super.dispose();
  }
}
