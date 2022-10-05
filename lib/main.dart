import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';

import './pages/freee.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DesktopWindow.setWindowSize(const Size(450, 600));
  await DesktopWindow.setMinWindowSize(const Size(450, 600));
  await DesktopWindow.setMaxWindowSize(const Size(600, 800));

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
