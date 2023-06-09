// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This sample demonstrates using CanPopScope to get the correct behavior from
// system back gestures when there are nested Navigator widgets.

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => _LinksPage(
          title: 'Home page',
          backgroundColor: Colors.indigo,
          buttons: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/one');
              },
              child: const Text('Go to a normal route on this Navigator'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/nested_navigator');
              },
              child: const Text('Go to a page with a nested Navigator'),
            ),
          ],
        ),
        '/one': (BuildContext context) => _LinksPage(
          title: 'Page one',
          backgroundColor: Colors.indigo.withRed(255),
        ),
        '/nested_navigator': (BuildContext context) => _NestedNavigatorsPage(
        ),
      },
    );
  }
}

class _NestedNavigatorsPage extends StatefulWidget {
  const _NestedNavigatorsPage();

  @override
  State<_NestedNavigatorsPage> createState() => _NestedNavigatorsPageState();
}

class _NestedNavigatorsPageState extends State<_NestedNavigatorsPage> {
  final GlobalKey<NavigatorState> _nestedNavigatorKey = GlobalKey<NavigatorState>();
  bool popEnabled = true;

  @override
  Widget build(BuildContext context) {
    final BuildContext rootContext = context;
    return CanPopScope(
      popEnabled: popEnabled,
      onPop: () {
        if (popEnabled) {
          return;
        }
        _nestedNavigatorKey.currentState!.pop();
      },
      child: Navigator(
        key: _nestedNavigatorKey,
        onHistoryChanged: (NavigatorState navigatorState) {
          final bool nextPopEnabled = !navigatorState.canPop();
          if (nextPopEnabled != popEnabled) {
            setState(() {
              popEnabled = nextPopEnabled;
            });
          }
          Navigator.defaultOnHistoryChanged(navigatorState);
        },
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (BuildContext context) {
                  return _LinksPage(
                    title: 'Nested once - home route',
                    backgroundColor: Colors.limeAccent,
                    onBack: () {
                      Navigator.of(rootContext).pop();
                    },
                    buttons: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/two');
                        },
                        child: const Text('Go to another route in this nested Navigator'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(rootContext).pop();
                        },
                        child: const Text('Go back out of nested nav'),
                      ),
                    ],
                  );
                },
              );
            case '/two':
              return MaterialPageRoute(
                builder: (BuildContext context) {
                  return _LinksPage(
                    backgroundColor: Colors.limeAccent.withBlue(255),
                    title: 'Nested once - page two',
                  );
                },
              );
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
        },
      ),
    );
  }
}

class _LinksPage extends StatelessWidget {
  const _LinksPage ({
    required this.backgroundColor,
    this.buttons = const <Widget>[],
    required this.title,
    this.onBack,
  });

  final Color backgroundColor;
  final List<Widget> buttons;
  final VoidCallback? onBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(title),
            ...buttons,
            if (Navigator.of(context).canPop())
              TextButton(
                onPressed: onBack ?? () {
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
