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
    insertLine(line, PrefixType.echo);
    insertLine('', PrefixType.none);
    notifyListeners();
  }

  void output(String line) {
    insertLine(line, PrefixType.output);
    notifyListeners();
  }

  void exception(String line) {
    insertLine(line, PrefixType.exception);
    notifyListeners();
  }

  void run(String line) {
    insertLine(line, PrefixType.run);
    notifyListeners();
  }

  void none(String line) {
    insertLine(line, PrefixType.none);
    notifyListeners();
  }

  void insertLine(String line, PrefixType prefixType) {
    lines.insert(0, CommandLine(content: line, prefixType: prefixType));
  }
}
