import 'package:flutter/material.dart';
import 'package:freee_time_stamp/buttons.dart';

class RegisterKeys extends StatelessWidget {
  const RegisterKeys({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("キーを登録する"),
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.all(10),
                    child: EnableButton(
                        text: "戻る", onPressed: () => Navigator.pop(context)))
              ]),
        ));
  }
}
