import 'package:fl_scrcpy/scrcpy_helper.dart';
import 'package:fl_scrcpy/terminal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FlScrcpy extends StatefulWidget {
  const FlScrcpy({Key? key, this.height = 200}) : super(key: key);
  final double height;

  @override
  _FlScrcpyState createState() => _FlScrcpyState();
}

class _FlScrcpyState extends State<FlScrcpy> {
  late ScrcpyProcess scrcpyProcess;

  TerminalController controller = TerminalController();

  @override
  void initState() {
    super.initState();
    scrcpyProcess = ScrcpyProcess(terminalController: controller);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {});
  }

  @override
  Widget build(BuildContext context) {
    if (supportedPlatforms) {
      return SizedBox(
          height: widget.height,
          child: Row(children: [
            Expanded(
                flex: 1,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: scrcpyProcess.hasScrcpy
                        ? [
                            _ElevatedText(
                                text: 'scrcpy help',
                                onPressed: () {
                                  scrcpyProcess.help();
                                }),
                            if (scrcpyProcess.hasADB) ...[
                              _ElevatedText(
                                  text: 'adb devices',
                                  onPressed: () {
                                    scrcpyProcess.getDevices();
                                  }),
                              _ElevatedText(
                                  text: 'start screen',
                                  onPressed: () {
                                    scrcpyProcess.startScreen('181QGEYH226MJ');
                                  }),
                              _ElevatedText(
                                  text: 'full screen',
                                  onPressed: () {
                                    scrcpyProcess.setFullscreen();
                                  }),
                            ]
                          ]
                        : [
                            _ElevatedText(
                                text: 'Install\nscrcpy', onPressed: () {}),
                          ])),
            const SizedBox(width: 10),
            Expanded(flex: 3, child: TerminalView(controller: controller)),
          ]));
    }
    return const Center(child: Text('The platform is not supported'));
  }

  bool get supportedPlatforms =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows);
}

class _ElevatedText extends StatelessWidget {
  const _ElevatedText({Key? key, this.onPressed, required this.text})
      : super(key: key);
  final VoidCallback? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(text));
  }
}

// class _ScrcpyNotifier with ChangeNotifier {
//
//
//
//   bool get hasScrcpy => whichSync('scrcpy') != null;
//
//   Shell? _shell;
//
//   StreamSubscription<dynamic>? _listen;
//
//   ShellLinesController? _shellController;
//
//   ShellLinesController? get shellController => _shellController;
//
//   Shell cd([String? path]) {
//     _shell?.kill();
//     _shellController ??= ShellLinesController();
//     _shell = Shell(
//         stdout: _shellController!.sink,
//         workingDirectory: path,
//         verbose: true,
//         commentVerbose: true,
//         commandVerbose: true);
//     _listen = _shellController!.stream.listen(_outListen);
//     return _shell!;
//   }
//
//   void _outListen(event) {
//     terminal.write(event);
//   }
//
//   void _checkShell() {
//     if (_shell == null) cd();
//   }
//
//   Future<bool> run(String script) async {
//     _checkShell();
//     bool hasRun = true;
//     try {
//       await _shell!.run(script).onError((Object error, stackTrace) async {
//         return Future.error(error);
//       });
//     } catch (e) {
//       hasRun = false;
//     }
//     return hasRun;
//   }
//
//   void help() {
//     run('scrcpy --help');
//   }
//
//   @override
//   void dispose() {
//     _shell?.kill();
//     _shell = null;
//     _listen?.cancel();
//     _listen = null;
//     super.dispose();
//   }
// }
