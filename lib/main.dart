import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:freee_time_stamp/register_keys.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<dynamic> _availableTypes = [];
  String _accessToken = '';
  String _refreshToken = '';
  String _employeeId = '';
  String _companyId = '';
  String _clientId = '';
  String _clientSecret = '';

  Future<void> getAvailableTypes() async {
    await refreshAccessToken();

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
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
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
    await refreshAccessToken();

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
    String body = json.encode({
      'company_id': _companyId,
      'type': availableTypeToString(type),
    });

    await http.post(url, headers: headers, body: body);

    await getAvailableTypes();
  }

  Future<void> refreshAccessToken() async {
    final SharedPreferences prefs = await _prefs;

    var url = Uri.https(
      'accounts.secure.freee.co.jp',
      '/public_api/token',
    );
    Map<String, String> headers = {
      'Authorization': 'Bearer $_accessToken',
      'content-type': 'application/x-www-form-urlencoded'
    };
    Object body = {
      'grant_type': 'refresh_token',
      'client_id': _clientId,
      'client_secret': _clientSecret,
      'refresh_token': _refreshToken,
      'redirect_uri': 'ietf:wg:oauth:2.0:oob'
    };

    var response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String accessToken = jsonResponse['access_token'] as String;
      String refreshToken = jsonResponse['refresh_token'] as String;
      setState(() {
        _accessToken = accessToken;
        _refreshToken = refreshToken;
      });
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('refreshToken', refreshToken);
    } else {
      throw ErrorDescription('error status: ${response.statusCode}.');
    }
  }

  @override
  void initState() {
    super.initState();

    _prefs.then((SharedPreferences prefs) {
      setState(() {
        _accessToken = prefs.getString('accessToken') ?? '';
        _refreshToken = prefs.getString('refreshToken') ?? '';
        _employeeId = dotenv.env['EMPLOYEE_ID'] != ''
            ? dotenv.env['EMPLOYEE_ID'] as String
            : '';
        _companyId = dotenv.env['COMPANY_ID'] != ''
            ? dotenv.env['COMPANY_ID'] as String
            : '';
        _clientId = dotenv.env['CLIENT_ID'] != ''
            ? dotenv.env['CLIENT_ID'] as String
            : '';
        _clientSecret = dotenv.env['CLIENT_SECRET'] != ''
            ? dotenv.env['CLIENT_SECRET'] as String
            : '';
      });

      getAvailableTypes();
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
          ],
        ),
      ),
      floatingActionButton:
          SpeedDial(icon: Icons.settings, activeIcon: Icons.close, children: [
        SpeedDialChild(
          child: const Icon(Icons.cached),
          label: "更新",
          onTap: () => getAvailableTypes(),
        ),
        SpeedDialChild(
          child: const Icon(Icons.key),
          label: "トークンを登録する",
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RegisterKeysPage())),
        )
      ]),
    );
  }
}
