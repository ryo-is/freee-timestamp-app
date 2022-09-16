import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:freee_time_stamp/register_keys.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'buttons.dart';
import 'enums.dart';

class MenuItem {
  String text;
  Function action;

  MenuItem({required this.text, required this.action});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DesktopWindow.setWindowSize(const Size(450, 600));
  await dotenv.load(fileName: '.env.development');

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
  List<dynamic> _availableTypes = [];
  String _accessToken = '';
  // String _refreshToken = '';
  String _employeeId = '';
  String _companyId = '';

  final List<MenuItem> _menuItems = [MenuItem(text: 'キーを登録', action: () => {})];

  Future<void> getAvailableTypes() async {
    var url = Uri.https(
        'api.freee.co.jp',
        '/hr/api/v1/employees/$_employeeId/time_clocks/available_types',
        {'company_id': _companyId});
    Map<String, String> headers = {
      'Authorization': 'Bearer $_accessToken',
      'accept': 'application/json',
      'FREEE-VERSION': '2022-02-01'
    };

    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      List<dynamic> availableTypes =
          jsonResponse['available_types'] as List<dynamic>;
      setState(() {
        _availableTypes = availableTypes;
      });
    } else {
      throw ErrorDescription('error status: ${response.statusCode}.');
    }
  }

  Future<void> registerTimeClock(AvailableType type) async {
    var url = Uri.https(
      'api.freee.co.jp',
      '/hr/api/v1/employees/$_employeeId/time_clocks',
    );
    Map<String, String> headers = {
      'Authorization': 'Bearer $_accessToken',
      'content-type': 'application/json',
      'accept': 'application/json',
      'FREEE-VERSION': '2022-02-01'
    };
    String body = convert.json.encode({
      'company_id': _companyId,
      'type': availableTypeToString(type),
    });

    await http.post(url, headers: headers, body: body);

    await getAvailableTypes();
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _accessToken = dotenv.env['ACCESS_TOKEN'] != ''
          ? dotenv.env['ACCESS_TOKEN'] as String
          : '';
      // _refreshToken = dotenv.env['REFRESH_TOKEN'] != ''
      //     ? dotenv.env['REFRESH_TOKEN'] as String
      //     : '';
      _employeeId = dotenv.env['EMPLOYEE_ID'] != ''
          ? dotenv.env['EMPLOYEE_ID'] as String
          : '';
      _companyId = dotenv.env['COMPANY_ID'] != ''
          ? dotenv.env['COMPANY_ID'] as String
          : '';
    });

    getAvailableTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton(
            icon: const Icon(Icons.settings),
            itemBuilder: (BuildContext context) {
              return _menuItems.map((MenuItem item) {
                return PopupMenuItem(
                  child: Text(item.text),
                  onTap: () => item.action(),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_availableTypes
                    .where((element) => element == 'clock_in')
                    .isNotEmpty)
                  EnableButton(
                      text: '出勤する',
                      onPressed: () =>
                          registerTimeClock(AvailableType.clockIn)),
                if (_availableTypes
                    .where((element) => element == 'break_begin')
                    .isNotEmpty)
                  EnableButton(
                    text: '休憩する',
                    onPressed: () =>
                        registerTimeClock(AvailableType.breakBegin),
                    color: Colors.green,
                  ),
                if (_availableTypes
                    .where((element) => element == 'break_end')
                    .isNotEmpty)
                  EnableButton(
                    text: '休憩から戻る',
                    onPressed: () => registerTimeClock(AvailableType.breakEnd),
                    color: Colors.green,
                  ),
                if (_availableTypes
                    .where((element) => element == 'clock_out')
                    .isNotEmpty)
                  EnableButton(
                    text: '退勤する',
                    onPressed: () => registerTimeClock(AvailableType.clockOut),
                    color: Colors.red,
                  ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: EnableButton(
                text: 'キーを登録する',
                onPressed: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterKeys()))
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => getAvailableTypes(),
        child: const Icon(Icons.cached),
      ),
    );
  }
}
