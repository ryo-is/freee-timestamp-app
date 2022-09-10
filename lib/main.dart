import 'package:flutter/material.dart';
import 'buttons.dart';
import 'enums.dart';

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
      home: const MyHomePage(title: 'Freee TimeStamp App'),
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
            const Text(
              '現在のステータス',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              statusToString(_status),
              style: const TextStyle(fontSize: 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: (_status == Status.working)
                  ? [
                      const DisableButton(
                        text: "出勤する",
                      ),
                      EnableButton(
                          text: "休憩する",
                          onPressed: () => _changeStatus(Status.rest)),
                      EnableButton(
                          text: "退勤する",
                          onPressed: () => _changeStatus(Status.workout)),
                    ]
                  : (_status == Status.rest)
                      ? [
                          const DisableButton(
                            text: "出勤する",
                          ),
                          EnableButton(
                              text: "休憩から戻る",
                              onPressed: () => _changeStatus(Status.working)),
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
            )
          ],
        ),
      ),
    );
  }
}
