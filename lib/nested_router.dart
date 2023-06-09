// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This sample demonstrates using CanPopScope to get the correct behavior from
// system back gestures when using the Navigator 2.0 API.

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
                Navigator.of(context).pushNamed('/cantpop');
              },
              child: const Text('Go to a page where pop is blocked'),
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
        '/cantpop': (BuildContext context) => _LinksPage(
          title: 'Cannot pop page - back gesture is blocked',
          backgroundColor: Colors.indigo.withGreen(255),
          popEnabled: false,
        ),
        '/nested_navigator': (BuildContext context) => const _NestedNavigatorsPage(
        ),
      },
    );
  }
}

enum _Page {
  home,
  two,
  noPop,
}

class _NestedNavigatorsPage extends StatefulWidget {
  const _NestedNavigatorsPage();

  @override
  State<_NestedNavigatorsPage> createState() => _NestedNavigatorsPageState();
}

class _NestedNavigatorsPageState extends State<_NestedNavigatorsPage> {
  final List<_Page> _pages = <_Page>[_Page.home];

  bool get _popEnabled => _pages.length <= 1;

  @override
  Widget build(BuildContext context) {
    final BuildContext rootContext = context;
    return CanPopScope(
      popEnabled: _popEnabled,
      onPop: () {
        if (_popEnabled) {
          return;
        }
        setState(() {
          _pages.removeLast();
        });
      },
      child: Navigator(
        onPopPage: (Route<void> route, void result) {
          if (!route.didPop(null)) {
            return false;
          }
          setState(() {
            _pages.removeLast();
          });
          return true;
        },
        pages: _pages.map((_Page page) {
          switch (page) {
            case _Page.home:
              return MaterialPage(
                child: _LinksPage(
                  title: 'Nested once - home route',
                  backgroundColor: Colors.limeAccent,
                  onBack: () {
                    Navigator.of(rootContext).pop();
                  },
                  buttons: <Widget>[
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _pages.add(_Page.two);
                        });
                      },
                      child: const Text('Go to another route in this nested Navigator'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _pages.add(_Page.noPop);
                        });
                      },
                      child: const Text('Go to a page where popping is blocked'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(rootContext).pop();
                      },
                      child: const Text('Go back out of nested nav'),
                    ),
                  ],
                ),
              );
            case _Page.two:
              return MaterialPage(
                child: _LinksPage(
                  backgroundColor: Colors.limeAccent.withBlue(255),
                  title: 'Nested once - page two',
                ),
              );
            case _Page.noPop:
              return MaterialPage(
                child: _LinksPage(
                  title: 'Cannot pop page - back gesture is blocked',
                  backgroundColor: Colors.limeAccent.withRed(5),
                  popEnabled: false,
                ),
              );
          }
        }).toList(),
      ),
    );
  }
}

class _LinksPage extends StatelessWidget {
  const _LinksPage ({
    required this.backgroundColor,
    this.buttons = const <Widget>[],
    this.popEnabled,
    required this.title,
    this.onBack,
  });

  final Color backgroundColor;
  final List<Widget> buttons;
  final bool? popEnabled;
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
            if (popEnabled != null)
              CanPopScope(
                popEnabled: popEnabled!,
                child: const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}
