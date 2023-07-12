// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This sample demonstrates using CanPopScope to get the correct behavior from
// system back gestures when using the Navigator 2.0 API.

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
  final List<_Page> _pages = <_Page>[_Page.home];

  bool get _popEnabled => _pages.length <= 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PopScope(
        canPop: _popEnabled,
        onPopInvoked: (bool didPop) {
          if (didPop) {
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
              // This doesn't seem to work, but neither does it work on master with WillPopScopes.
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
