import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TerminalView extends StatefulWidget {
  const TerminalView({Key? key, required this.controller}) : super(key: key);
  final TerminalController controller;

  @override
  _TerminalViewState createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  TerminalController get controller => widget.controller;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  void listener() {
    setState(() {});
    scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(6),
      child: ListView.builder(
          reverse: true,
          controller: scrollController,
          itemCount: controller._line.length,
          itemBuilder: (_, int index) {
            var commandLine = controller._line[index];
            var prefixType = commandLine.prefixType;
            late Color prefixColor;
            late Color lineColor;
            late String prefix = '->';
            if (prefixType != PrefixType.none) {
              prefix = prefixType.name;
            }
            switch (prefixType) {
              case PrefixType.none:
                prefixColor = Colors.blue;
                lineColor = Colors.white;
                break;
              case PrefixType.output:
                prefixColor = Colors.blue;
                lineColor = Colors.white;
                break;
              case PrefixType.run:
                prefixColor = Colors.green;
                lineColor = Colors.white;
                break;
              case PrefixType.exception:
                prefixColor = Colors.red;
                lineColor = Colors.red;
                break;
              case PrefixType.echo:
                prefixColor = Colors.deepPurpleAccent;
                lineColor = Colors.deepPurpleAccent;
                break;
            }
            return Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                margin: const EdgeInsets.symmetric(vertical: 2),
                width: double.infinity,
                child: RichText(
                  text: TextSpan(
                      text: prefix + ' : ',
                      style: TextStyle(
                          color: prefixColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            recognizer: LongPressGestureRecognizer()
                              ..onLongPress = () {
                                Clipboard.setData(
                                    ClipboardData(text: commandLine.line));
                              },
                            text: commandLine.line,
                            style: TextStyle(
                                color: lineColor, fontWeight: FontWeight.w500))
                      ]),
                ));
          }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(listener);
  }
}

class CommandLine {
  CommandLine({required this.line, required this.prefixType});

  PrefixType prefixType;
  String line;
}

enum PrefixType {
  none,
  echo,
  output,
  run,
  exception,
}

const String shellPush = 'cdPush ';
const String shellPop = 'cdPop ';

class TerminalController with ChangeNotifier {
  final List<CommandLine> _line = [];

  void echo(String line) {
    _insertLine(line, PrefixType.echo);
    _insertLine('', PrefixType.none);
    notifyListeners();
  }

  void output(String line) {
    _insertLine(line, PrefixType.output);
    notifyListeners();
  }

  void exception(String line) {
    _insertLine(line, PrefixType.exception);
    notifyListeners();
  }

  void run(String line) {
    _insertLine(line, PrefixType.run);
    notifyListeners();
  }

  void none(String line) {
    _insertLine(line, PrefixType.none);
    notifyListeners();
  }

  void _insertLine(String line, PrefixType prefixType) {
    _line.insert(0, CommandLine(line: line, prefixType: prefixType));
  }
}

extension ExtensionString on String {
  /// 移出头部指定 [prefix] 不包含不移出
  String removePrefix(String prefix) {
    if (!startsWith(prefix)) return this;
    return substring(prefix.length);
  }
}
