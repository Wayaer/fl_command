import 'package:flutter/foundation.dart';

class CommandLine {
  CommandLine({required this.content, required this.prefixType});

  PrefixType prefixType;
  String content;
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
  final List<CommandLine> lines = [];

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
    lines.insert(0, CommandLine(content: line, prefixType: prefixType));
  }
}

extension ExtensionString on String {
  /// 移出头部指定 [prefix] 不包含不移出
  String removePrefix(String prefix) {
    if (!startsWith(prefix)) return this;
    return substring(prefix.length);
  }
}
