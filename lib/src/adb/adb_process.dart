import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_command/fl_command.dart';
import 'package:fl_command/src/platform.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

class AdbProcess extends ProcessShell {
  AdbProcess(
      {super.workingDirectory,
      super.throwOnError = true,
      super.includeParentEnvironment = true,
      super.runInShell,
      super.stdoutEncoding = const Utf8Codec(),
      super.stderrEncoding = const Utf8Codec(),
      super.stdin,
      super.stdout,
      super.stderr,
      super.verbose = true,
      super.commandVerbose = true,
      super.commentVerbose = false});

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

  /// start adb server
  Future<bool> startServer() async {
    final result = await runAdb(['start-server']);
    return result?.exitCode == 0;
  }

  /// kill adb server
  Future<bool> killServer() async {
    final result = await runAdb(['kill-server']);
    return result?.exitCode == 0;
  }

  /// reboot adb server
  Future<void> rebootServer() async {
    await killServer();
    await startServer();
  }

  final List<DeviceInfoModel> _devices = [];

  List<DeviceInfoModel> get devices => _devices;

  /// 获取设备列表
  Future<List<DeviceInfoModel>> getDevices() async {
    _devices.clear();
    final result = await runAdb(['devices']);
    if (result != null) {
      for (var value in result.outLines) {
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
    final result = await runAdb(['-s', device, 'shell', 'getprop']);
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
    final result = await runAdb(['-s', device, 'shell', 'ps']);
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
    final result = await runAdb(['-s', device, 'shell', 'wm', 'size']);
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
    final result = await runAdb(['-s', device, 'shell', 'wm', 'density']);
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
  Future<String?> getCurrentUInode(String device,
      {String outPath = '/sdcard/ui.xml'}) async {
    final result = await runAdb([
      '-s',
      device,
      'shell',
      'uiautomator',
      'dump',
      '--compressed',
      outPath
    ]);
    if (result?.exitCode == 0) {
      return outPath;
    }
    return null;
  }

  /// 从设备中获取文件
  Future<String?> pull(String device, String fromPath, String outPath) async {
    final result =
        await runAdb(['-s', device, 'shell', 'pull', fromPath, outPath]);
    if (result?.exitCode == 0) {
      return outPath;
    }
    return null;
  }

  /// 推送文件到设备
  Future<ProcessResult?> push(
      String device, String fromPath, String outPath) async {
    return await runAdb(['-s', device, 'shell', 'push', fromPath, outPath]);
  }

  /// 重启设备
  Future<ProcessResult?> reboot(
      String device, String fromPath, String outPath) async {
    return await runAdb(['-s', device, 'shell', 'reboot']);
  }

  /// 查看设备AndroidId
  Future<String?> getAndroidId(
      String device, String fromPath, String outPath) async {
    final result = await runAdb(
        ['-s', device, 'shell', 'settings', 'get', 'secure', 'android_id']);
    final outLines = result?.outLines;
    if (outLines != null || outLines!.isNotEmpty) {
      return outLines.first;
    }
    return null;
  }

  /// 查看前台Activity
  Future<String?> getForegroundActivity(String device) async {
    final result = await runAdb([
      '-s',
      device,
      'shell',
      'dumpsys',
      'window',
      '|',
      'grep',
      'mCurrentFocus',
    ]);
    var outLines = result?.outLines;
    if (outLines != null && outLines.isNotEmpty) {
      return outLines.first.replaceAll("mCurrentFocus=", "");
    }
    return null;
  }

  /// 安装apk
  Future<bool> installApk(String device, String apkPath) async {
    final result = await runAdb([
      '-s',
      device,
      'install',
      '-r',
      '-d',
      apkPath,
    ]);
    return result?.exitCode == 0;
  }

  /// 卸载apk
  Future<bool> uninstallApk(String device, String packageName) async {
    final result = await runAdb([
      '-s',
      device,
      'uninstall',
      packageName,
    ]);
    return result?.exitCode == 0;
  }

  /// 停止运行应用
  Future<bool> stopApp(String device, String packageName) async {
    final result =
        await runAdb(['-s', device, 'shell', 'am', 'force-stop', packageName]);
    return result?.exitCode == 0;
  }

  /// 启动应用
  Future<bool> startApp(String device, String packageName) async {
    final activity = await getLaunchActivityForApp(device, packageName);
    if (activity != null) {
      final result = await runAdb([
        '-s',
        device,
        'shell',
        'am',
        'start',
        '-n',
        activity,
      ]);
      return result?.exitCode == 0;
    }
    return false;
  }

  /// 获取启动Activity
  Future<String?> getLaunchActivityForApp(
      String device, String packageName) async {
    var result = await runAdb([
      '-s',
      device,
      'shell',
      'dumpsys',
      'package',
      packageName,
      '|',
      'grep',
      '-A',
      '1',
      'MAIN',
    ]);

    if (result != null && result.outLines.isNotEmpty) {
      for (var value in result.outLines) {
        if (value.contains("$packageName/")) {
          return value.substring(
              value.indexOf("$packageName/"), value.indexOf(" filter"));
        }
      }
    }
    return null;
  }

  /// 重启应用
  Future<void> restartApp(String device, String packageName) async {
    await stopApp(device, packageName);
    await startApp(device, packageName);
  }

  /// 清除指定App数据
  Future<bool> clearAppData(String device, String packageName) async {
    final result =
        await runAdb(['-s', device, 'shell', 'pm', 'clear', packageName]);
    return result?.exitCode == 0;
  }

  /// 保存应用APK到电脑
  Future<bool> saveAppApk(
      String device, String packageName, String savePath) async {
    final result = await runAdb([
      '-s',
      device,
      'shell',
      'pm',
      'path',
      packageName,
    ]);
    if (result != null && result.outLines.isNotEmpty) {
      final path = result.outLines.first.replaceAll("package:", "");
      final saveResult = await runAdb([
        '-s',
        device,
        'pull',
        path,
        savePath,
      ]);
      return saveResult?.exitCode == 0;
    }
    return false;
  }

  /// 截图保存到电脑
  Future<bool> screenshot(String device, String savePath) async {
    final fileName = 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
    final result = await runAdb([
      '-s',
      device,
      'shell',
      'screencap',
      '-p',
      '/sdcard/$fileName',
    ]);
    if (result?.exitCode == 0) {
      final pullResult =
          await pull(device, '/sdcard/$fileName', '$savePath/$fileName');
      if (pullResult != null) {
        await deleteFile(device, '/sdcard/$fileName');
        return true;
      }
    }
    return false;
  }

  /// 删除文件
  Future<bool> deleteFile(String device, String filePath) async {
    final result = await runAdb(["-s", device, "shell", "rm", "-rf", filePath]);
    return result?.exitCode == 0;
  }

  /// 录屏并保存到电脑
  Future<String?> startRecordScreen(ProcessShell shell, String device) async {
    final filePath =
        '/sdcard/screenrecord_${DateTime.now().millisecondsSinceEpoch}.mp4';
    if (_adbPath != null) {
      final result = await shell.runArgs(_adbPath!, [
        '-s',
        device,
        'shell',
        'screenrecord',
        filePath,
      ]);
      if (result?.exitCode == 0) return filePath;
    }
    return null;
  }

  /// 停止录屏
  Future<bool> stopRecord(ProcessShell shell, String device, String fromPath,
      String outPath) async {
    shell.kill();
    final result = await pull(device, fromPath, outPath);
    if (result != null) {
      final deleteResult = await deleteFile(device, fromPath);
      return deleteResult;
    }
    return false;
  }

  /// 查看所有包名
  Future<List<String>> packages(
    String device, {
    bool only3 = false,
    bool onlySystem = false,
    bool onlyEnable = false,
    bool onlyDisable = false,
    bool onlyInstall = false,
    bool onlyUninstall = false,
    String? user,
  }) async {
    final result = await runAdb([
      '-s',
      device,
      'shell',
      'pm',
      'list',
      'packages',
      if (user != null) '--user',
      if (only3) '-3',
      if (onlySystem) '-s',
      if (onlyEnable) '-e',
      if (onlyDisable) '-d',
      if (onlyInstall) '-i',
      if (onlyUninstall) '-l'
    ]);
    if (result != null && result.outLines.isNotEmpty) {
      return result.outLines
          .map((e) => e.replaceFirst('package:', '').trim())
          .toList();
    }
    return [];
  }
}
