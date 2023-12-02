import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_command/fl_command.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

class ScrcpyProcess extends ProcessShell {
  ScrcpyProcess(
      {String? workingDirectory,
      bool throwOnError = true,
      bool includeParentEnvironment = true,
      bool? runInShell,
      Encoding stdoutEncoding = const Utf8Codec(),
      Encoding stderrEncoding = const Utf8Codec(),
      Stream<List<int>>? stdin,
      StreamSink<List<int>>? stdout,
      StreamSink<List<int>>? stderr,
      bool verbose = true,
      bool commandVerbose = true,
      bool commentVerbose = false}) {
    _shell = Shell(
        workingDirectory: workingDirectory ?? getHome,
        throwOnError: throwOnError,
        includeParentEnvironment: includeParentEnvironment,
        runInShell: runInShell,
        stderrEncoding: const Utf8Codec(),
        stdoutEncoding: const Utf8Codec(),
        stdin: stdin,
        stdout: stdout,
        stderr: stderr,
        verbose: verbose,
        commandVerbose: commandVerbose,
        commentVerbose: commentVerbose,
        environment: Platform.environment);
  }

  /// shell
  late Shell _shell;

  Shell get shell => _shell;

  /// scrcpy path
  String? _scrcpyPath;

  String? get scrcpyPath => _scrcpyPath;

  /// 下载scrcpy文件
  Future<String?> download() async {
    var directory = await getTemporaryDirectory();
    var filePath =
        "${directory.path}${Platform.pathSeparator}scrcpy${Platform.pathSeparator}scrcpy.zip";
    var url = downloadUrl();
    if (url == null || url.isEmpty) return null;
    var response = await Dio().download(url, filePath);
    if (response.statusCode == 200) {
      return unzipPlatformToolsFile(filePath, 'scrcpy');
    }
    return null;
  }

  /// scrcpy 下载地址
  String? downloadUrl() {
    return null;
  }

  /// 获取Scrcpy路径
  Future<String?> checkScrcpy() async {
    var executable = Platform.isWindows ? "where" : "which";
    var result = await runArgs(executable, ['adb']);
    _scrcpyPath = result?.stdout.toString().trim();
    return _scrcpyPath ??= await download();
  }

  ///  run Scrcpy
  Future<ProcessResult?> runScrcpy(String executable, List<String> arguments,
      {ProcessShellProcess? onProcess}) async {
    await checkScrcpy();
    if (_scrcpyPath == null) return null;
    return runArgs(_scrcpyPath!, arguments, onProcess: onProcess);
  }
}
