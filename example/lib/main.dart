import 'package:example/page/adb_page.dart';
import 'package:example/page/scrcpy_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      navigatorKey: GlobalWayUI().navigatorKey,
      scaffoldMessengerKey: GlobalWayUI().scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      home: const _App()));
}

class _App extends StatefulWidget {
  const _App();

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<_App> {
  @override
  void initState() {
    super.initState();
    DesktopWindowsSize.iPhone4P7.set();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Universal(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            children: [
          Button('adb script', onPressed: () {
            _push(const FlADB());
          }),
          Button('scrcpy script', onPressed: () {
            _push(const FlScrcpy());
          }),
        ]));
  }

  Future<void> _push(Widget widget) async {
    await push(Scaffold(
        appBar: AppBar(title: const Text("")),
        body: Universal(isStack: true, children: [
          (supportedPlatforms
              ? widget
              : const Center(child: Text('The platform is not supported'))),
        ])));
  }

  bool get supportedPlatforms => !isWeb && isDesktop;
}

class Button extends StatelessWidget {
  const Button(this.text, {this.onPressed, super.key});

  final VoidCallback? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(onPressed: onPressed, child: Text(text)));
  }
}
