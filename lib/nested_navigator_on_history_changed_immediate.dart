// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// An example of a root Navigator that immediately delegates to a nested
// Navigator in the root route.  In this case, it's necessary to manually update
// the SystemNavigator with the pop status.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const _NestedNavigatorsPage(
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
            if (nextPopEnabled) {
              // It's up to the application developer to update this in this
              // case.
              SystemNavigator.updateNavigationStackStatus(false);
            }
          }
        },
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (BuildContext context) {
                  return _LinksPage(
                    title: 'Home page of the nested Navigator',
                    backgroundColor: Colors.indigo,
                    onBack: () {
                      Navigator.of(rootContext).pop();
                    },
                    buttons: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/nested_navigator_home/two');
                        },
                        child: const Text('Go to another route in this nested Navigator'),
                      ),
                    ],
                  );
                },
              );
            case '/nested_navigator_home/two':
              return MaterialPageRoute(
                builder: (BuildContext context) {
                  return _LinksPage(
                    backgroundColor: Colors.indigo.withBlue(255),
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

