import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

void main() {
  runApp(const ExtendedWidgetsApp(home: _App()));
}

class _App extends StatefulWidget {
  const _App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<_App> {
  @override
  void initState() {
    super.initState();
    setDesktopSize(const Size(300, 600));
  }

  @override
  Widget build(BuildContext context) {
    return const ExtendedScaffold(children: []);
  }
}

class Button extends SimpleButton {
  const Button(
    String text, {
    Key? key,
    GestureTapCallback? onTap,
  }) : super(text: text, onTap: onTap, key: key);
}

Future<bool> setDesktopSize(Size size) =>
    Curiosity().desktop.focusDesktop().then((value) {
      if (value) Curiosity().desktop.setDesktopSize(size);
      return value;
    });
