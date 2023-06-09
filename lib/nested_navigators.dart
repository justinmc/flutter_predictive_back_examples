// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';

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
        builder: (BuildContext context, GoRouterState state) => _NestedNavigatorsPage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => _HomePage(),
        '/nested_navigators': (BuildContext context) => _NestedNavigatorsPage(),
      },
    );
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
              title: const Text('Nested Navigator route'),
              subtitle: const Text('This route has another Navigator widget in addition to the one inside MaterialApp above.'),
              onTap: () {
                //context.push('/nested_navigators');
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
    // TODO(justinmc): Could this be a Navigator?
    final BuildContext rootContext = context;

    return CanPopScope(
      popEnabled: false,
      /*
      onPop: () {
        print('justin onPop $popEnabled');
        return;
        if (popEnabled) {
          return;
        }
        _nestedNavigatorKey.currentState!.pop();
      },
      */
    /*
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      */
      child: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (BuildContext context) {
                  return _LinksPage(
                    title: 'Nested once - home route',
                    backgroundColor: Colors.indigo,
                    onBack: () {
                      //rootContext.pop();
                      Navigator.of(rootContext).pop();
                    },
                    buttons: <Widget>[
                      TextButton(
                        onPressed: () {
                          //context.push('/two');
                          Navigator.of(context).pushNamed('/two');
                        },
                        child: const Text('Go to another route in this nested Navigator'),
                      ),
                      /*
                      TextButton(
                        onPressed: () {
                          context.push('/another_layer');
                        },
                        child: const Text('Go one layer deeper in nested navigation'),
                      ),
                      */
                    ],
                  );
                },
              );
            case '/two':
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
      /*
      child: Router<Object>.withConfig(
        restorationScopeId: 'router-2',
        config: GoRouter(
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
                  /*
                  TextButton(
                    onPressed: () {
                      context.push('/another_layer');
                    },
                    child: const Text('Go one layer deeper in nested navigation'),
                  ),
                  */
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
        ),
      ),
      */
    );
  }
}

class _LinksPage extends StatelessWidget {
  const _LinksPage ({
    required this.backgroundColor,
    this.buttons = const <Widget>[],
    this.onBack,
    required this.title,
    this.canPop = true,
  });

  final Color backgroundColor;
  final List<Widget> buttons;
  final bool canPop;
  final VoidCallback? onBack;
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
              onPressed: onBack ?? () {
                Navigator.of(context).pop();
                context.pop();
              },
              /*
              onPressed: () {
                context.pop();
              },
              */
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

