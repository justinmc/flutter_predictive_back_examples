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
        '/': (BuildContext context) => _HomePage(),
        '/nested_navigators': (BuildContext context) => _NestedNavigatorsPage(),
      },
    );
  }
}

class _HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nested Navigators Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Home Page'),
            const Text('A system back gesture here will exit the app.'),
            const SizedBox(height: 20.0),
            ListTile(
              title: const Text('Nested Navigator route'),
              subtitle: const Text('This route has another Navigator widget in addition to the one inside MaterialApp above.'),
              onTap: () {
                Navigator.of(context).pushNamed('/nested_navigators');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NestedNavigatorsPage extends StatefulWidget {
  @override
  State<_NestedNavigatorsPage> createState() => _NestedNavigatorsPageState();
}

class _NestedNavigatorsPageState extends State<_NestedNavigatorsPage> {

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            final BuildContext rootContext = context;
            return MaterialPageRoute(
              builder: (BuildContext context) => _LinksPage(
                title: 'Nested once - home route',
                backgroundColor: Colors.indigo,
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
                      Navigator.of(context).pushNamed('/another_layer');
                    },
                    child: const Text('Go one layer deeper in nested navigation'),
                  ),
                ],
              ),
            );
          case '/two':
            return MaterialPageRoute(
              builder: (BuildContext context) => _LinksPage(
                backgroundColor: Colors.indigo.withBlue(255),
                title: 'Nested once - page two',
                onBack: () {
                  Navigator.of(context).pop();
                },
              ),
            );
          case '/another_layer':
            return MaterialPageRoute(
              builder: (BuildContext context) => _NestedNavigatorsPageNestedAgain(
              ),
            );
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
      },
    );
  }
}

class _NestedNavigatorsPageNestedAgain extends StatefulWidget {
  @override
  State<_NestedNavigatorsPageNestedAgain> createState() => _NestedNavigatorsPageNestedAgainState();
}

class _NestedNavigatorsPageNestedAgainState extends State<_NestedNavigatorsPageNestedAgain> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            final BuildContext rootContext = context;
            return MaterialPageRoute(
              builder: (BuildContext context) => _LinksPage(
                title: 'Nested twice - home route',
                backgroundColor: Colors.amberAccent,
                onBack: () {
                  Navigator.of(rootContext).pop();
                },
                buttons: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/another_one');
                    },
                    child: const Text('Go to another route in this nested Navigator'),
                  ),
                ],
              ),
            );
          case '/another_one':
            return MaterialPageRoute(
              builder: (BuildContext context) => _LinksPage(
                backgroundColor: Colors.amberAccent.withRed(200),
                canPop: false,
                title: 'Nested twice - page two',
                onBack: () {
                  Navigator.of(context).pop();
                },
              ),
            );
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
      },
    );
  }
}

class _LinksPage extends StatelessWidget {
  const _LinksPage ({
    required this.backgroundColor,
    this.buttons = const <Widget>[],
    required this.onBack,
    required this.title,
    this.canPop = true,
  });

  final Color backgroundColor;
  final List<Widget> buttons;
  final bool canPop;
  final VoidCallback onBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    final Scaffold child = Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(title),
            //const Text('A system back here will go back to Nested Navigators Page One'),
            ...buttons,
            TextButton(
              onPressed: onBack,
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );

    if (!canPop) {
      /*
      return CanPopScope(
        popEnabled: false,
        child: child,
      );
      */
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: child,
      );
    }
    return child;
  }
}
