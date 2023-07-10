import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => _HomePage(),
        '/two': (BuildContext context) => _PageTwo(),
      },
    );
  }
}

class _HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saveable form example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Home Page'),
            ListTile(
              title: const Text('Next page'),
              subtitle: const Text('Another saveable form on a second route'),
              onTap: () {
                Navigator.of(context).pushNamed('/two');
              },
            ),
            const SizedBox(height: 20.0),
            _SaveableForm(),
          ],
        ),
      ),
    );
  }
}

class _PageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Confirmation Dialog Example'),
        ),
        body: Center(
          child: _SaveableForm(),
        ),
      ),
    );
  }
}

class _SaveableForm extends StatefulWidget {
  @override
  State<_SaveableForm> createState() => _SaveableFormState();
}

class _SaveableFormState extends State<_SaveableForm> {
  final TextEditingController _controller = TextEditingController();
  String _savedValue = '';
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final bool nextIsDirty = _savedValue != _controller.text;
    if (nextIsDirty == _isDirty) {
      return;
    }
    setState(() {
      _isDirty = nextIsDirty;
    });
  }

  Future<void> _showDialog() async {
    final bool? shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Any unsaved changes will be lost!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes, discard my changes'),
              onPressed: () {
                Navigator.pop(context, true);
                //Navigator.maybePop(context, true);
              },
            ),
            TextButton(
              child: const Text('No, continue editing'),
              onPressed: () {
                Navigator.pop(context, false);
                //Navigator.maybePop(context, false);
              },
            ),
          ],
        );
      },
    );

    if (shouldDiscard ?? false) {
      _goBack();
    }
  }

  void _save(String? value) {
    setState(() {
      _savedValue = value ?? '';
    });
  }

  Future<void> _goBack() async {
    final bool maybePopped = await Navigator.maybePop(context);
    print('justin _goBack $maybePopped');
    if (maybePopped) {
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('If the field below is unsaved, a confirmation dialog will be shown on back.'),
          const SizedBox(height: 20.0),
          Form(
            popEnabled: !_isDirty,
            onPopped: (bool didPop) {
              if (didPop) {
                return;
              }
              _showDialog();
            },
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _controller,
                  onFieldSubmitted: (String? value) {
                    _save(value);
                  },
                ),
                TextButton(
                  onPressed: () {
                    _save(_controller.text);
                  },
                  child: Row(
                    children: <Widget>[
                      const Text('Save'),
                      if (_controller.text.isNotEmpty)
                        Icon(
                          _isDirty ? Icons.warning : Icons.check,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              if (_isDirty) {
                _showDialog();
                return;
              }
              _goBack();
            },
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }
}
