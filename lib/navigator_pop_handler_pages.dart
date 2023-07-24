import 'package:flutter/material.dart';

// This example shows NavigatorPopHandler working with Navigator.pages, and
// where that Navigator starts with multiple routes on the stack.

void main() => runApp(const NavigatorPopHandlerApp());

enum _TabPage {
  home,
  one,
}

class NavigatorPopHandlerApp extends StatelessWidget {
  const NavigatorPopHandlerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => _HomePage(),
        '/nested_navigators': (BuildContext context) => const NestedNavigatorsPage(),
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

class NestedNavigatorsPage extends StatefulWidget {
  const NestedNavigatorsPage({super.key});

  @override
  State<NestedNavigatorsPage> createState() => _NestedNavigatorsPageState();
}

class _NestedNavigatorsPageState extends State<NestedNavigatorsPage> {
  final GlobalKey<NavigatorState> _nestedNavigatorKey = GlobalKey<NavigatorState>();

  List<_TabPage> pages = <_TabPage>[
    _TabPage.home,
    _TabPage.one,
  ];

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPop: () {
        _nestedNavigatorKey.currentState!.pop();
      },
      child: Navigator(
        key: _nestedNavigatorKey,
        onPopPage: (Route<void> route, void result) {
          if (!route.didPop(null)) {
            return false;
          }
          setState(() {
            pages = <_TabPage>[
              ...pages,
            ]..removeLast();
          });
          return true;
        },
        pages: pages.map((_TabPage page) {
          switch (page) {
            case _TabPage.home:
              return MaterialPage<void>(
                child: Scaffold(
                  backgroundColor: Colors.lightGreen,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Nested Navigator route 1/2'),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              pages = <_TabPage>[
                                ...pages,
                                _TabPage.one,
                              ];
                            });
                          },
                          child: const Text('Go to a deeper route in this nested Navigator'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            case _TabPage.one:
              return MaterialPage<void>(
                child: Scaffold(
                  backgroundColor: Colors.lightGreen,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Nested Navigator route 2/2'),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              pages = <_TabPage>[
                                ...pages,
                              ]..removeLast();
                            });
                          },
                          child: const Text('Go back'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
          }
        }).toList(),
      ),
    );
  }
}

