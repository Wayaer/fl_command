import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:fl_command/src/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

typedef ProcessShellProcess = void Function(Process process);

class ProcessShell {
  ProcessShell(
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

  /// macos /  linux /  windows \
  String get pathSeparator => Platform.pathSeparator;

  late Shell _shell;

  Shell get shell => _shell;

  String? get getHome =>
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

  Future<ProcessResult?> runArgs(String executable, List<String> arguments,
      {ProcessShellProcess? onProcess}) async {
    try {
      return await _shell.runExecutableArguments(executable, arguments,
          onProcess: onProcess);
    } catch (e) {
      debugPrint("ProcessShell runArgs : $e");
      return null;
    }
  }

  Future<List<ProcessResult>> run(String executable, List<String> arguments,
      {ProcessShellProcess? onProcess}) async {
    try {
      return await _shell.run(executable, onProcess: onProcess);
    } catch (e) {
      debugPrint("ProcessShell run : $e");
      return [];
    }
  }

  /// 解压并删除文件
  Future<String> unzipPlatformToolsFile(
      String zipPath, String unzipDirName) async {
    final libraryDirectory = await getApplicationSupportDirectory();
    final unzipPath =
        "${libraryDirectory.path}$pathSeparator$unzipDirName$pathSeparator";

    if (isWindows) {
      final inputStream = InputFileStream(zipPath);
      final archive = ZipDecoder().decodeBuffer(inputStream);
      extractArchiveToDisk(archive, unzipPath);
    } else {
      await runArgs("rm", ["-rf", unzipPath]);
      await runArgs("unzip", [zipPath, "-d", unzipPath]);
      await runArgs("rm", ["-rf", zipPath]);
    }
    return unzipPath;
  }

  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) =>
      _shell.kill(signal);
}
