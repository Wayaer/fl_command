import 'package:example/page/adb_page.dart';
import 'package:example/page/scrcpy_page.dart';
import 'package:flutter/foundation.dart';
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
    setDesktopSize(const Size(350, 650));
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        padding: const EdgeInsets.all(10),
        appBar: AppBar(
            backgroundColor: Colors.lightBlue,
            elevation: 0,
            title: const Text('FlCommand')),
        children: [
          Button('adb script', onTap: () {
            _push(const FlADB());
          }),
          Button('scrcpy script', onTap: () {
            _push(const FlScrcpy());
          }),
        ]);
  }

  Future<void> _push(Widget widget) async {
    setDesktopSize(const Size(600, 600));
    await push(_FlPage(widget));
    setDesktopSize(const Size(350, 650));
  }
}

class _FlPage extends StatelessWidget {
  const _FlPage(this.widget, {Key? key}) : super(key: key);
  final Widget widget;

  @override
  Widget build(BuildContext context) =>
      ExtendedScaffold(isStack: true, children: [
        (supportedPlatforms
                ? widget
                : const Center(child: Text('The platform is not supported')))
            .expand,
        const Positioned(left: 12, top: 12, child: BackButton()),
      ]);

  bool get supportedPlatforms =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows);
}

class Button extends SimpleButton {
  Button(
    String text, {
    Key? key,
    GestureTapCallback? onTap,
  }) : super(
          text: text,
          textStyle: const TextStyle(color: Colors.white, height: 1),
          onTap: onTap,
          key: key,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.lightBlue, borderRadius: BorderRadius.circular(6)),
        );
}

Future<bool> setDesktopSize(Size size) =>
    Curiosity().desktop.focusDesktop().then((value) {
      if (value) Curiosity().desktop.setDesktopSize(size);
      return value;
    });
