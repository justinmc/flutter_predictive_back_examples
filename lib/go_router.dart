// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(_MyApp());

class _MyApp extends StatefulWidget {

  @override
  State<_MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
  final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => _LinksPage(
          title: 'Home page',
          backgroundColor: Colors.indigo,
          buttons: <Widget>[
            TextButton(
              onPressed: () {
                context.push('/one');
              },
              child: const Text('Go to one'),
            ),
          ],
        ),
      ),
      GoRoute(
        path: '/one',
        builder: (BuildContext context, GoRouterState state) => _LinksPage(
          title: 'Page one',
          backgroundColor: Colors.indigo.withRed(255),
          buttons: <Widget>[
            TextButton(
              onPressed: () {
                context.push('/one/two');
              },
              child: const Text('Go to one/two'),
            ),
          ],
        ),
      ),
      GoRoute(
        path: '/one/two',
        builder: (BuildContext context, GoRouterState state) => _LinksPage(
          title: 'Page one/two',
          backgroundColor: Colors.indigo.withBlue(255),
        ),
      ),
    ],
  );

  void _routerChanged() {
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      SystemNavigator.updateNavigationStackStatus(_router.canPop());
    });
  }

  @override
  void initState() {
    super.initState();
    _router.addListener(_routerChanged);
  }

  @override
  void dispose() {
    _router.removeListener(_routerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

class _LinksPage extends StatelessWidget {
  const _LinksPage ({
    required this.backgroundColor,
    this.buttons = const <Widget>[],
    required this.title,
  });

  final Color backgroundColor;
  final List<Widget> buttons;
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
            if (GoRouter.of(context).canPop())
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('Go back'),
              ),
          ],
        ),
      ),
    );
  }
}
