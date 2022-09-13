import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';

import 'buttons.dart';
import 'enums.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DesktopWindow.setWindowSize(const Size(450, 600));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Freee 勤怠打刻アプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Freee 勤怠打刻アプリ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Status _status = Status.working;

  void _changeStatus(Status status) {
    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(10),
              child: Column(children: [
                const Text(
                  '現在のステータス',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  statusToString(_status),
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ]),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: (_status == Status.working)
                  ? [
                      const DisableButton(
                        text: "出勤する",
                      ),
                      EnableButton(
                        text: "休憩する",
                        onPressed: () => _changeStatus(Status.rest),
                        color: Colors.green,
                      ),
                      EnableButton(
                        text: "退勤する",
                        onPressed: () => _changeStatus(Status.workout),
                        color: Colors.red,
                      ),
                    ]
                  : (_status == Status.rest)
                      ? [
                          const DisableButton(
                            text: "出勤する",
                          ),
                          EnableButton(
                            text: "休憩から戻る",
                            onPressed: () => _changeStatus(Status.working),
                            color: Colors.green,
                          ),
                          const DisableButton(
                            text: "退勤する",
                          ),
                        ]
                      : [
                          EnableButton(
                              text: "出勤する",
                              onPressed: () => _changeStatus(Status.working)),
                          const DisableButton(
                            text: "休憩する",
                          ),
                          const DisableButton(
                            text: "退勤する",
                          ),
                        ],
            ),
            // const Icon(
            //   Icons.cached,
            //   size: 48,
            //   color: Colors.blue,
            // )
          ],
        ),
      ),
    );
  }
}
