import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_command/fl_command.dart';
import 'package:fl_command/src/adb/device_info.dart';
import 'package:fl_command/src/adb/enum.dart';
import 'package:fl_command/src/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  Future<ProcessResult?> runAdb(List<String> arguments,
      {ProcessShellProcess? onProcess}) async {
    await checkAdb();
    if (adbPath == null) return null;
    return runArgs(adbPath!, arguments, onProcess: onProcess);
  }

  final List<DeviceInfoModel> _devices = [];

  List<DeviceInfoModel> get devices => _devices;

  /// 获取设备列表
  Future<List<DeviceInfoModel>> getDevices() async {
    _devices.clear();
    var devices = await runAdb(['devices']);
    if (devices != null) {
      for (var value in devices.outLines) {
        if (value.contains("List of devices attached")) {
          continue;
        }
        if (value.contains("device")) {
          var line = value.split("\t");
          if (line.isEmpty) {
            continue;
          }
          final info = await getDeviceInfo(line.first);
          if (info != null) _devices.add(info);
        }
      }
    }
    return _devices;
  }

  /// 获取设备品牌
  Future<DeviceInfoModel?> getDeviceInfo(String device) async {
    var result = await runAdb(['-s', device, 'shell', 'getprop']);
    if (result != null && result.outLines.isNotEmpty) {
      Map<String, String> info = {};
      for (var element in result.outLines) {
        element = element.trim().replaceFirst("[", "");
        final kv = element.split(']: [');
        final map = <String, String>{};
        if (kv.isNotEmpty) {
          final k = kv.first.toString().trim();
          map[k] = kv.length == 2
              ? kv.last.toString().trim().replaceFirst("]", "")
              : "";
        }
        info.addAll(map);
      }
      return DeviceInfoModel(id: device, info: info);
    }
    return null;
  }

  /// 获取设备进程信息
  Future<List<DeviceProcessModel>> getProcessInfo(String device) async {
    var result = await runAdb(['-s', device, 'shell', 'ps']);
    if (result != null && result.outLines.isNotEmpty) {
      final list = <DeviceProcessModel>[];
      for (var element in result.outLines) {
        final strList = element.split(" ")
          ..removeWhere((element) => element.trim().isEmpty);
        if (strList.length == DeviceProcessModel.l) {
          list.add(DeviceProcessModel(strList));
        }
      }
    }
    return [];
  }

  Future<Size?> getResolution(String device) async {
    var result = await runAdb(['-s', device, 'shell', 'wm', 'size']);
    if (result != null && result.outLines.isNotEmpty) {
      try {
        final str = result.outLines.first;
        final wh = str.split(": ").last.split("x");
        if (wh.length == 2) {
          return Size(double.parse(wh.first), double.parse(wh[1]));
        }
      } catch (e) {
        debugPrint("getResolution ${e.toString()}");
      }
    }
    return null;
  }

  Future<Size?> getDensity(String device) async {
    var result = await runAdb(['-s', device, 'shell', 'wm', 'density']);
    if (result != null && result.outLines.isNotEmpty) {
      try {
        final str = result.outLines.first;
        final wh = str.split(": ").last.split("x");
        if (wh.length == 2) {
          return Size(double.parse(wh.first), double.parse(wh[1]));
        }
      } catch (e) {
        debugPrint("getDensity ${e.toString()}");
      }
    }
    return null;
  }

  /// 输入文字
  Future<ProcessResult?> pressInputText(String device, String text) async {
    return await runAdb(['-s', device, 'shell', 'input', 'text', text]);
  }

  /// 执行 InputKeyEvent 事件
  Future<ProcessResult?> pressInputKeyEvent(
      String device, InputKeyEvent keyEvent) async {
    return await runAdb(
        ['-s', device, 'shell', 'input', 'keyevent', keyEvent.id]);
  }

  /// 执行 pressInputTap 事件
  Future<ProcessResult?> pressInputTap(String device, Offset offset) async {
    return await runAdb([
      '-s',
      device,
      'shell',
      'input',
      'tap',
      '${offset.dx}',
      '${offset.dy}'
    ]);
  }

  /// 执行 pressInputSwipe 事件
  Future<ProcessResult?> pressInputSwipe(String device, Offset o1, Offset o2,
      {int? ms}) async {
    return await runAdb([
      '-s',
      device,
      'shell',
      'input',
      'swipe',
      '${o1.dx}',
      '${o1.dy}',
      '${o2.dx}',
      '${o2.dy}',
      if (ms != null) '$ms',
    ]);
  }

  /// 执行 pressInputDragAndDrop 事件
  Future<ProcessResult?> pressInputDragAndDrop(
      String device, InputKeyEvent keyEvent) async {
    return await runAdb(
        ['-s', device, 'shell', 'input', 'draganddrop', keyEvent.id]);
  }

  /// 执行 pressInputRoll 事件
  Future<ProcessResult?> pressInputRoll(
      String device, InputKeyEvent keyEvent) async {
    return await runAdb(['-s', device, 'shell', 'input', 'roll', keyEvent.id]);
  }

  /// 执行 pressInputEvent 事件
  Future<ProcessResult?> pressInputEvent(
      String device, InputKeyEvent keyEvent) async {
    return await runAdb(['-s', device, 'shell', 'input', 'event', keyEvent.id]);
  }

  /// 获取当前UI节点
  Future<ProcessResult?> getCurrentUInode(String device,
      {String outPath = '/sdcard/ui.xml'}) async {
    return await runAdb([
      '-s',
      device,
      'shell',
      'uiautomator',
      'dump',
      '--compressed',
      outPath
    ]);
  }

  /// 从设备中获取文件
  Future<ProcessResult?> pull(
      String device, String fromPath, String outPath) async {
    return await runAdb(['-s', device, 'shell', 'pull', fromPath, outPath]);
  }

  /// 推送文件到设备
  Future<ProcessResult?> push(
      String device, String fromPath, String outPath) async {
    return await runAdb(['-s', device, 'shell', 'push', fromPath, outPath]);
  }
}
