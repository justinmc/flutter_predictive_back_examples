import 'package:flutter/material.dart';

void main() => runApp(_MyApp());

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/nested_navigator',
      routes: <String, WidgetBuilder>{
        '/nested_navigator': (BuildContext context) => _NestedNavigatorsPage(),
      },
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
    // This WillPopScope will have an effect because it is outside of the nested
    // Navigator widget. Returning false here will prevent back gestures.
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Nested Navigators Example'),
                    ),
                    body: Center(
                      // This WillPopScope has no effect because it's inside of
                      // the nested Navigator widget.
                      child: WillPopScope(
                        onWillPop: () async {
                          return false;
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Nested Navigator Page'),
                            Text('A WillPopScope here, inside of a nested Navigator, has no effect. A back gesture will succeed anyway.'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
        },
      ),
    );
  }
}

