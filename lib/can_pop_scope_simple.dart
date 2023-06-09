import 'package:flutter/material.dart';

class CanPopScopeSimplePage extends StatefulWidget {
  const CanPopScopeSimplePage({super.key});

  @override
  State<CanPopScopeSimplePage> createState() => _CanPopScopeSimplePageState();
}

class _CanPopScopeSimplePageState extends State<CanPopScopeSimplePage> {
  final GlobalKey nestedNavigatorKey = GlobalKey();
  bool popEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Simple CanPopScope Page'),
            const CanPopScopeButton(),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}

class CanPopScopeButton extends StatefulWidget {
  const CanPopScopeButton({super.key});

  @override
  State<CanPopScopeButton> createState() => _CanPopScopeButtonState();
}

class _CanPopScopeButtonState extends State<CanPopScopeButton> {
  bool popEnabled = true;

  @override
  Widget build(BuildContext context) {
    return CanPopScope(
      popEnabled: popEnabled,
      onPop: () {
        print('justin onPop from CanPopScopeButton');
      },
      child: TextButton(
        onPressed: () {
          setState(() {
            popEnabled = !popEnabled;
          });
        },
        child: Text('popEnabled is ${popEnabled ? 'true' : 'false'}. Tap to toggle.'),
      ),
    );
  }
}
