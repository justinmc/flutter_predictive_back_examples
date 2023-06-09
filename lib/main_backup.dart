import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: <String, Widget Function(BuildContext)>{
        '/': (BuildContext context) =>
            const MyHomePage(title: 'Flutter Demo Home Page'),
        '/second-page': (BuildContext context) =>
            const MyOtherPage(title: 'Flutter Demo Second Page'),
      },
      //navigatorObservers: <RouteObserver<ModalRoute<void>>>[ routeObserver ],
      navigatorObservers: <NavigatorObserver>[ routeObserver ],
    );
  }
}

class _Page extends StatefulWidget {
  const _Page({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {// with RouteAware {
  /*
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // Route was pushed onto navigator and is now topmost route.
    //print('justin didPush');
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.
    //print('justin didPopNext');
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //SystemNavigator.updateNavigationStackStatus(false);
          showLicensePage(context: context);
          //Navigator.of(context).pop();
          //SystemNavigator.pop();
        },
        tooltip: 'Empty',
        child: const Icon(Icons.hourglass_empty),
      ),
      body: widget.child,
    );
  }
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: title,
      /*
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/second-page');
              },
              child: const Text('Go to page 2'),
            ),
          ],
        ),
      ),
      */
      /*
      child: CanPopScope(
        popEnabled: true,
        child: CanPopScope(
          popEnabled: true,
          */
      /*
      child: WillPopScope(
        onWillPop: () {
          print('justin outer willpopscopes willpop callback');
          return Future<bool>.value(true);
        },
        child: WillPopScope(
          onWillPop: () {
            print('justin nested willpopscopes willpop callback');
            return Future<bool>.value(true);
          },
          */
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/second-page');
                  },
                  child: const Text('Push page 2'),
                ),
                CanPopButton(),
                const BackButton(),
              ],
            ),
          ),
    );
  }
}

class MyOtherPage extends StatelessWidget {
  const MyOtherPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: title,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/');
              },
              child: const Text('Push page 1'),
            ),
            const BackButton(),
          ],
        ),
      ),
    );
  }
}

class CanPopButton extends StatefulWidget {
  @override
  _CanPopButtonState createState() => _CanPopButtonState();
}

class _CanPopButtonState extends State<CanPopButton> {
  bool popEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
    /*
    return CanPopScope(
      popEnabled: popEnabled,
      child: TextButton(
        onPressed: () {
          setState(() {
            popEnabled = !popEnabled;
          });
        },
        child: Text('Toggle can pop to ${popEnabled ? 'false' : 'true'}'),
      ),
    );
    */
  }
}

