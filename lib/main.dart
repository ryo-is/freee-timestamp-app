import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';

import 'package:freee_time_stamp/pages/freee.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class TimeClock {
  String type = '';
  String typeString = '';
  String datetime = '';

  TimeClock(
      {required this.type, required this.typeString, required this.datetime});
}

class ResponseObject {
  bool ok = true;
  String message = '';

  ResponseObject({required this.ok, required this.message});
}

class WrappedAPIObject<T> {
  Function function = () {};
  final T? arg;

  WrappedAPIObject({required this.function, this.arg});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DesktopWindow.setWindowSize(const Size(450, 600));
  await DesktopWindow.setMinWindowSize(const Size(450, 600));

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
        home: const FreeePage(title: 'Freee 勤怠打刻アプリ'),
        navigatorObservers: [routeObserver]);
  }
}
