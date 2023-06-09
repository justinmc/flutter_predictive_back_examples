// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

void main() => runApp(_MyApp());

class _MyApp extends StatelessWidget {
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
              child: const Text('Go to one'),
            ),
          ],
        ),
        '/one': (BuildContext context) => _LinksPage(
          title: 'Page one',
          backgroundColor: Colors.indigo.withRed(255),
          buttons: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/one/two');
              },
              child: const Text('Go to one/two'),
            ),
          ],
        ),
        '/one/two': (BuildContext context) => _LinksPage(
          title: 'Page one/two',
          backgroundColor: Colors.indigo.withBlue(255),
        ),
      },
    );
  }
}

class _LinksPage extends StatelessWidget {
  const _LinksPage ({
    required this.backgroundColor,
    this.buttons = const <Widget>[],
    this.onBack,
    required this.title,
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

