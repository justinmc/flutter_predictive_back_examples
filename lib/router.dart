// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This sample demonstrates using PopScope to make Android system back gestures
// work with the Navigator.pages API.

import 'package:flutter/material.dart';

enum _Page {
  home,
  two,
  noPop,
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey _navigatorKey = GlobalKey();
  final List<_Page> _pages = <_Page>[_Page.home];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          },
        ),
      ),
      // This PopScope controls the root Navigator (in MaterialApp above). It
      // should only allow popping when exiting the app. Otherwise, the nested
      // Navigator below should handle pops.
      home: PopScope(
        canPop: _pages.length <= 1,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) {
            return;
          }
          // This handles back gestures and physical back button presses.
          final NavigatorState? navigatorState = _navigatorKey.currentState as NavigatorState?;
          navigatorState?.maybePop();
        },
        child: Navigator(
          key: _navigatorKey,
          onDidRemovePage: (Page<void>? page) {
            setState(() {
              _pages.removeLast();
            });
          },
          pages: _pages.map((_Page page) {
            switch (page) {
              case _Page.home:
                return MaterialPage(
                  child: _LinksPage(
                    title: 'Home',
                    backgroundColor: Colors.limeAccent,
                    buttons: <Widget>[
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _pages.add(_Page.two);
                          });
                        },
                        child: const Text('Go to another normal route'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _pages.add(_Page.noPop);
                          });
                        },
                        child: const Text('Go to a page where popping is blocked'),
                      ),
                    ],
                  ),
                );
              case _Page.two:
                return MaterialPage(
                  child: _LinksPage(
                    backgroundColor: Colors.limeAccent.withBlue(255),
                    title: 'Page two',
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
  });

  final Color backgroundColor;
  final List<Widget> buttons;
  final bool? popEnabled;
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Go back'),
              ),
            if (popEnabled != null)
              // This PopScope controls popping in the nested Navigator.
              PopScope(
                canPop: popEnabled!,
                child: const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}
