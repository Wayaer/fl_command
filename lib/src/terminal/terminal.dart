import 'package:fl_command/fl_command.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TerminalView extends StatefulWidget {
  const TerminalView(
      {Key? key,
      required this.controller,
      this.padding = const EdgeInsets.all(6),
      this.style = const TerminalStyle()})
      : super(key: key);
  final TerminalController controller;
  final TerminalStyle style;

  final EdgeInsetsGeometry padding;

  @override
  State<TerminalView> createState() => _TerminalViewState();
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
      color: widget.style.backgroundColor,
      padding: widget.padding,
      child: ListView.builder(
          reverse: true,
          controller: scrollController,
          itemCount: controller.lines.length,
          itemBuilder: (_, int index) {
            var commandLine = controller.lines[index];
            return Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                margin: const EdgeInsets.symmetric(vertical: 2),
                width: double.infinity,
                child: richText(commandLine));
          }),
    );
  }

  RichText richText(CommandLine commandLine) {
    var prefixType = commandLine.prefixType;
    late String prefix = '->';
    if (prefixType != PrefixType.none) {
      prefix = prefixType.name;
    }
    return RichText(
        textAlign: TextAlign.start,
        text: TextSpan(
            text: '$prefix : ',
            style: widget.style.prefixStyle
                .copyWith(color: widget.style._prefixColor(prefixType)),
            children: [
              TextSpan(
                  recognizer: LongPressGestureRecognizer()
                    ..onLongPress = () {
                      Clipboard.setData(
                          ClipboardData(text: commandLine.content));
                    },
                  text: commandLine.content,
                  style: widget.style.prefixStyle
                      .copyWith(color: widget.style._contentColor(prefixType)))
            ]));
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(listener);
  }
}

class TerminalColor {
  const TerminalColor(this.prefixColor, this.contentColor);

  final Color prefixColor;
  final Color contentColor;
}

class TerminalStyle {
  const TerminalStyle({
    this.backgroundColor = Colors.black,
    this.prefixStyle =
        const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    this.contentStyle = const TextStyle(fontWeight: FontWeight.w500),
    this.noneColor = const TerminalColor(Colors.blue, Colors.white),
    this.echoColor =
        const TerminalColor(Colors.deepPurpleAccent, Colors.deepPurpleAccent),
    this.outputColor = const TerminalColor(Colors.blue, Colors.white),
    this.runColor = const TerminalColor(Colors.green, Colors.green),
    this.exceptionColor = const TerminalColor(Colors.red, Colors.red),
  });

  final TerminalColor noneColor;
  final TerminalColor echoColor;
  final TerminalColor outputColor;
  final TerminalColor runColor;
  final TerminalColor exceptionColor;

  final TextStyle prefixStyle;
  final TextStyle contentStyle;

  final Color backgroundColor;

  Color _prefixColor(PrefixType type) {
    switch (type) {
      case PrefixType.none:
        return noneColor.prefixColor;
      case PrefixType.echo:
        return echoColor.prefixColor;
      case PrefixType.output:
        return outputColor.prefixColor;
      case PrefixType.run:
        return runColor.prefixColor;
      case PrefixType.exception:
        return exceptionColor.prefixColor;
    }
  }

  Color _contentColor(PrefixType type) {
    switch (type) {
      case PrefixType.none:
        return noneColor.contentColor;
      case PrefixType.echo:
        return echoColor.contentColor;
      case PrefixType.output:
        return outputColor.contentColor;
      case PrefixType.run:
        return runColor.contentColor;
      case PrefixType.exception:
        return exceptionColor.contentColor;
    }
  }
}
