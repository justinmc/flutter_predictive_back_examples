// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(_MyApp());

class _MyApp extends StatelessWidget {
  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => _HomePage(),
      ),
      GoRoute(
        path: '/nested_navigators',
        builder: (BuildContext context, GoRouterState state) => _NestedGoRoutersPage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
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
              title: const Text('Nested go_router route'),
              subtitle: const Text('This route has another go_router in addition to the one used with MaterialApp above.'),
              onTap: () {
                context.push('/nested_navigators');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NestedGoRoutersPage extends StatefulWidget {
  @override
  State<_NestedGoRoutersPage> createState() => _NestedGoRoutersPageState();
}

class _NestedGoRoutersPageState extends State<_NestedGoRoutersPage> {
  late final GoRouter _router;
  final GlobalKey<NavigatorState> _nestedNavigatorKey = GlobalKey<NavigatorState>();

  // If the nested navigator has routes that can be popped, then we want to
  // block the root navigator from handling the pop so that the nested navigator
  // can handle it instead.
  bool get _popEnabled {
    // canPop will throw an error if called before build. Is this the best way
    // to avoid that?
    return _nestedNavigatorKey.currentState == null ? true : !_router.canPop();
  }

  void _onRouterChanged() {
    // Here the _router reports the location correctly, but canPop is still out
    // of date.  Hence the post frame callback.
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    final BuildContext rootContext = context;
    _router = GoRouter(
      navigatorKey: _nestedNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) => _LinksPage(
            title: 'Nested once - home route',
            backgroundColor: Colors.indigo,
            onBack: () {
              rootContext.pop();
            },
            buttons: <Widget>[
              TextButton(
                onPressed: () {
                  context.push('/two');
                },
                child: const Text('Go to another route in this nested Navigator'),
              ),
            ],
          ),
        ),
        GoRoute(
          path: '/two',
          builder: (BuildContext context, GoRouterState state) => _LinksPage(
            backgroundColor: Colors.indigo.withBlue(255),
            title: 'Nested once - page two',
          ),
        ),
      ],
    );

    _router.addListener(_onRouterChanged);
  }

  @override
  void dispose() {
    _router.removeListener(_onRouterChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      popEnabled: _popEnabled,
      onPopped: (bool success) {
        if (success) {
          return;
        }
        _router.pop();
      },
      child: Router<Object>.withConfig(
        restorationScopeId: 'router-2',
        config: _router,
      ),
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
            //const Text('A system back here will go back to Nested Navigators Page One'),
            ...buttons,
            TextButton(
              onPressed: onBack ?? () {
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
