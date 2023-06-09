// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This sample demonstrates using CanPopScope to get the correct behavior from
// system back gestures when there are nested Navigator widgets.

import 'package:flutter/material.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() => runApp(_MyApp());

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //navigatorObservers: <NavigatorObserver>[ routeObserver ],
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

class _NestedNavigatorsPageState extends State<_NestedNavigatorsPage> with WidgetsBindingObserver {
  final GlobalKey nestedNavigatorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<bool> didPopRoute() async {
    // This is never called. The root WidgetsApp gets it first and pops its
    // Navigator.
    print('justin _NestedNavigatorPage.didPopRoute');
    assert(mounted);

    final NavigatorState navigator = nestedNavigatorKey.currentState as NavigatorState;
    return navigator.maybePop();
  }

  @override
  void routerReportsNewRouteInformation(RouteInformation routeInformation, {RouteInformationReportingType type = RouteInformationReportingType.none}) {
    print('justin routerReports $routeInformation');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState? nestedNavigatorState = nestedNavigatorKey.currentState as NavigatorState?;
    final bool canPop = nestedNavigatorState?.canPop() == true;
    print('justin build ${nestedNavigatorState?.canPop()}, $canPop');
    return Navigator(
      key: nestedNavigatorKey,
      initialRoute: 'nested_navigators/one',
      observers: <NavigatorObserver>[ routeObserver ],
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case 'nested_navigators/one':
            final BuildContext rootContext = context;
            return MaterialPageRoute(
              builder: (BuildContext context) => _NestedNavigatorListener(
                child: NestedNavigatorsPageOne(
                  onBack: () {
                    Navigator.of(rootContext).pop();
                  },
                ),
              ),
            );
          case 'nested_navigators/one/another_one':
            return MaterialPageRoute(
              builder: (BuildContext context) => _NestedNavigatorListener(
                child: NestedNavigatorsPageTwo(
                  onBack: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            );
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
      },
    );
  }
}

class _NestedNavigatorListener extends StatefulWidget {
  const _NestedNavigatorListener({
    required this.child,
  });

  final Widget child;

  @override
  State<_NestedNavigatorListener> createState() => _NestedNavigatorListenerState();
}

// RouteAware seems to not call didPop when I call Navigator.pop. Wait, which Navigator
// is it listening to? The nested one. Doesn't call didPop for either Navigator, though.
class _NestedNavigatorListenerState extends State<_NestedNavigatorListener> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    print('justin _NestedNavigatorListenerState is being disposed');
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    print('justin observer: didPush');
    setState(() {});
  }

  @override
  void didPushNext() {
    print('justin observer: didPushNext');
    setState(() {});
  }

  @override
  void didPop() {
    print('justin observer: didPop');
    setState(() {});
  }

  @override
  void didPopNext() {
    print('justin observer: didPopNext');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ModalRoute route = ModalRoute.of(context)!;
    final NavigatorState nestedNavigatorState = Navigator.of(context);
    print('justin building listener. canpop? ${nestedNavigatorState.canPop()}. Is root? ${nestedNavigatorState == Navigator.of(context, rootNavigator: true)}');
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: widget.child,
    );
    /*
    return CanPopScope(
      //popEnabled: !nestedNavigatorState.canPop(),
      popEnabled: false,
      onPop: () {
        print('justin onPop');
        /*
        final NavigatorState newNestedNavigatorState = nestedNavigatorKey.currentState as NavigatorState;
        final bool newCanPop = newNestedNavigatorState.canPop();
        print('justin onPop. New: $newCanPop, Old: $canPop');
        if (newCanPop) {
          newNestedNavigatorState.pop();
          // Because now that we've popped, canPop could be false.
          setState(() {});
        }
        */
      },
      child: widget.child,
    );
  */
  }
}

class NestedNavigatorsPageOne extends StatelessWidget {
  const NestedNavigatorsPageOne({
    required this.onBack,
    super.key,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Nested Navigators Page One'),
            const Text('A system back here returns to the home page.'),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('nested_navigators/one/another_one');
              },
              child: const Text('Go to another route in this nested Navigator'),
            ),
            TextButton(
              // Can't use Navigator.of(context).pop() because this is the root
              // route, so it can't be popped. The Navigator above this needs to
              // be popped.
              onPressed: onBack,
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}

class NestedNavigatorsPageTwo extends StatelessWidget {
  const NestedNavigatorsPageTwo({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.withBlue(255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Nested Navigators Page Two'),
            const Text('A system back here will go back to Nested Navigators Page One'),
            TextButton(
              onPressed: onBack,
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
