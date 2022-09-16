import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_command/fl_command.dart';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

typedef FlProcessOutput = void Function(String event);

class FlProcess with ChangeNotifier {
  FlProcess(
      {ShellLinesController? shellController,
      this.terminalController,
      String? path,
      this.onOutput}) {
    this.shellController = shellController ?? ShellLinesController();
    shell = Shell(
        stdout: this.shellController.sink,
        workingDirectory: path,
        environment: Platform.environment,
        verbose: true,
        commentVerbose: true,
        commandVerbose: true);
    _listen = this.shellController.stream.listen(_outListen);
  }

  void _outListen(event) {
    currentOutput.add(event);
    onOutput?.call(event);
    terminalController?.output(event);
  }

  final List<String> currentOutput = [];

  /// 当前 run 的 进程
  Process? process;

  /// 命令输入控制器
  late TerminalController? terminalController;

  /// shell 控制器
  late ShellLinesController shellController;

  /// shell
  late Shell shell;

  late FlShell flShell;

  /// 输入内容回调
  final FlProcessOutput? onOutput;

  /// 输入内容监听
  StreamSubscription<dynamic>? _listen;

  Future<List<ProcessResult>> runScript(String script) async {
    terminalController?.run(script);
    currentOutput.clear();
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

// extension StringExtension on String {
//   /// 移出头部指定 [prefix] 不包含不移出
//   String removePrefix(String prefix) {
//     if (!startsWith(prefix)) return this;
//     return substring(prefix.length);
//   }
//
//   /// 移出尾部指定 [suffix] 不包含不移出
//   String removeSuffix(String suffix) {
//     if (!endsWith(suffix)) return this;
//     return substring(0, length - suffix.length);
//   }
//
//   /// 移出头部指定长度
//   String removePrefixLength(int l) => substring(l, length);
//
//   /// 移出尾部指定长度
//   String removeSuffixLength(int l) => substring(0, l);
// }

// 自实现的Process基于dart:io库中的Process.start
typedef ProcessCallBack = void Function(String output);

const exitKey = 'process_exit';

class FlShell {
  FlShell({this.environment = const {}});

  final Map<String, String> environment;

  Process? _process;
  bool? _isRoot;

  String get shPath {
    switch (Platform.operatingSystem) {
      case 'linux':
        return 'sh';
      case 'macos':
        return 'sh';
      case 'windows':
        return 'wsl';
      case 'android':
        return '/system/bin/sh';
      default:
        return 'sh';
    }
  }

  Future<void> ensureInitialized() async {
    if (_process == null) await _init();
  }

  Future<void> _init() async {
    Map<String, String> temp = getEnvironment();
    for (String key in environment.keys) {
      temp[key] = environment[key] ?? '';
    }
    _process = await Process.start(
      shPath,
      <String>[],
      includeParentEnvironment: true,
      runInShell: false,
      environment: temp,
    );
    processStdout = _process!.stdout.asBroadcastStream();
    processStderr = _process!.stderr.asBroadcastStream();
    // 不加这个，会出现err输出会累计到最后输出
    processStderr!.transform(utf8.decoder).listen((event) {
      debugPrint('$event  NiProcess');
    });
  }

  Stream<List<int>>? processStdout;
  Stream<List<int>>? processStderr;

  Lock lock = Lock();

  Future<String> run(
    String script, {
    ProcessCallBack? callback,
    bool getStdout = true,
    bool getStderr = false,
  }) async {
    return lock.synchronized(() async {
      Completer<String> resultComp = Completer();
      if (_process == null) {
        /// 如果初始为空需要城初始化Process
        await _init();
      }
      final StringBuffer buffer = StringBuffer();
      // 加上换行符
      if (!script.endsWith('\n')) {
        script += '\n';
      }
      _process!.stdin.write(script);
      // print('脚本====>$script');
      _process!.stdin.write('echo $exitKey\n');
      if (getStderr) {
        // print('等待错误');
        processStderr!.transform(utf8.decoder).every((String out) {
          // print('processStdout错误输出为======>$out');
          buffer.write(out);
          callback?.call(out);
          return !resultComp.isCompleted;
        });
      }
      if (getStdout) {
        processStdout!.transform(utf8.decoder).every(
          (String out) {
            // print('processStdout输出为======>$out');
            buffer.write(out);
            callback?.call(out);
            if (out.contains(exitKey) && !resultComp.isCompleted) {
              // Log.e('${script.trim()}释放');
              resultComp.complete(
                buffer.toString().replaceAll(exitKey, '').trim(),
              );
              return false;
            }
            return true;
          },
        );
      }
      // Log.e('${script.trim()}等待返回');
      String result = await resultComp.future;
      // Log.e('${script.trim()}返回');
      return result;
    });
  }

  Future<bool> isRoot() async {
    if (_isRoot != null) return _isRoot ?? false;
    String idResult = await run("su -c 'id -u'");
    return _isRoot = idResult == '0';
  }

  static Map<String, String> getEnvironment() {
    if (kIsWeb) return {};
    final Map<String, String> map = Map.from(Platform.environment);
    map['PATH'] = '${RuntimeEnvironment().binPath}:${map['PATH'] ?? ''}';
    debugPrint(map.toString());
    return map;
  }
}
