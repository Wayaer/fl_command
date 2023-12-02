import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_command/fl_command.dart';
import 'package:fl_command/src/platform.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

class AdbProcess extends ProcessShell {
  AdbProcess(
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

  /// adb path
  String? _adbPath;

  String? get adbPath => _adbPath;

  /// 下载adb文件
  Future<String?> download() async {
    final directory = await getTemporaryDirectory();
    final filePath =
        "${directory.path}${pathSeparator}adb${pathSeparator}adb.zip";
    var url = downloadUrl();
    if (url == null || url.isEmpty) return null;
    var response = await Dio().download(url, filePath);
    if (response.statusCode == 200) {
      return unzipPlatformToolsFile(filePath, 'adb');
    }
    return null;
  }

  /// adb 下载地址
  String? downloadUrl() {
    if (isMacOS) {
      return "https://dl.google.com/android/repository/platform-tools-latest-darwin.zip";
    } else if (isWindows) {
      return "https://dl.google.com/android/repository/platform-tools-latest-windows.zip";
    } else if (isLinux) {
      return "https://dl.google.com/android/repository/platform-tools-latest-linux.zip";
    }
    return null;
  }

  /// 获取adb路径
  Future<String?> checkAdb() async {
    var executable = Platform.isWindows ? "where" : "which";
    var result = await runArgs(executable, ['adb']);
    _adbPath = result?.stdout.toString().trim();
    return _adbPath ??= await download();
  }

  ///  run Adb
  Future<ProcessResult?> runAdb(String executable, List<String> arguments,
      {ProcessShellProcess? onProcess}) async {
    await checkAdb();
    if (adbPath == null) return null;
    return runArgs(adbPath!, arguments, onProcess: onProcess);
  }
}
