import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:freee_time_stamp/register_keys.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'buttons.dart';
import 'enums.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class TimeClock {
  String type = '';
  String datetime = '';

  TimeClock({required this.type, required this.datetime});
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
        navigatorObservers: [routeObserver]);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RouteAware {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<dynamic> _availableTypes = [];
  TimeClock _timeClock = TimeClock(type: 'まだ打刻していません', datetime: '');
  String _accessToken = '';
  String _refreshToken = '';
  String _employeeId = '';
  String _companyId = '';
  String _clientId = '';
  String _clientSecret = '';

  bool _isLoading = false;
  ResponseStatus _responseStatus = ResponseStatus.loading;

  void startLoading() {
    setState(() {
      _responseStatus = ResponseStatus.loading;
      _isLoading = true;
    });
  }

  void finishLoading(ResponseStatus status) {
    setState(() {
      _responseStatus = status;
    });
    Future.delayed(Duration(seconds: status == ResponseStatus.error ? 0 : 1))
        .then((_) => {
              setState(() {
                _isLoading = false;
              })
            });
  }

  String convertAvailableTypeToString(String type) {
    switch (type) {
      case ('clock_in'):
        return '出勤';
      case ('break_begin'):
        return '休憩開始';
      case ('break_end'):
        return '休憩終了';
      case ('clock_out'):
        return '退勤';
      default:
        return 'まだ打刻していません';
    }
  }

  void showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: const Text('エラーが発生しました'),
              content: Text(message),
              actions: [
                CupertinoDialogAction(
                  child: const Text('閉じる'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  Future<void> getAvailableTypes() async {
    startLoading();

    if (_accessToken == '') {
      finishLoading(ResponseStatus.error);
      showErrorDialog('アクセストークンを登録してください');
      return;
    }

    bool ok = await refreshAccessToken();
    if (!ok) {
      finishLoading(ResponseStatus.error);
      return;
    }

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

      await getTimeClocks();
    } else {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorDescription = jsonResponse['error_description'] as String;
      showErrorDialog(errorDescription);
      finishLoading(ResponseStatus.error);
      return;
    }

    finishLoading(ResponseStatus.success);
  }

  Future<void> registerTimeClock(AvailableType type) async {
    startLoading();

    if (_accessToken == '') {
      finishLoading(ResponseStatus.error);
      showErrorDialog('アクセストークンを登録してください');
      return;
    }

    bool ok = await refreshAccessToken();
    if (!ok) {
      finishLoading(ResponseStatus.error);
      return;
    }

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

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      finishLoading(ResponseStatus.success);
      await getAvailableTypes();
    } else {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorDescription = jsonResponse['error_description'] as String;
      showErrorDialog(errorDescription);
      finishLoading(ResponseStatus.error);
      return;
    }
  }

  Future<void> getTimeClocks() async {
    startLoading();

    if (_accessToken == '') {
      finishLoading(ResponseStatus.error);
      showErrorDialog('アクセストークンを登録してください');
      return;
    }

    bool ok = await refreshAccessToken();
    if (!ok) {
      finishLoading(ResponseStatus.error);
      return;
    }

    var url = Uri.https(
        'api.freee.co.jp',
        '/hr/api/v1/employees/$_employeeId/time_clocks',
        {'company_id': _companyId});
    Map<String, String> headers = {
      'Authorization': 'Bearer $_accessToken',
      'accept': 'application/json',
      'FREEE-VERSION': '2022-02-01'
    };

    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as List<dynamic>;
      if (jsonResponse.isNotEmpty) {
        var lastTimeClock = jsonResponse.last;
        final formatter = DateFormat('yyyy/MM/dd(E) HH:mm');
        DateTime datetime = DateTime.parse(lastTimeClock['datetime']);
        String formatDate = formatter.format(datetime);
        TimeClock timeClock = TimeClock(
            type: convertAvailableTypeToString(lastTimeClock['type']),
            datetime: formatDate);
        setState(() {
          _timeClock = timeClock;
        });
      }
    } else {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorDescription = jsonResponse['error_description'] as String;
      showErrorDialog(errorDescription);
      finishLoading(ResponseStatus.error);
      return;
    }

    finishLoading(ResponseStatus.success);
  }

  Future<bool> refreshAccessToken() async {
    if (_accessToken == '') {
      showErrorDialog('アクセストークンを登録してください');
      return false;
    }

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
      return true;
    } else {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorDescription = jsonResponse['error_description'] as String;
      showErrorDialog(errorDescription);
      return false;
    }
  }

  void init() {
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
  void initState() {
    super.initState();

    init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        _timeClock.type,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _timeClock.datetime,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
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
                        onPressed: () =>
                            registerTimeClock(AvailableType.breakEnd),
                        color: Colors.green,
                      ),
                    if (_availableTypes
                        .where((element) => element == 'clock_out')
                        .isNotEmpty)
                      EnableButton(
                        text: '退勤する',
                        onPressed: () =>
                            registerTimeClock(AvailableType.clockOut),
                        color: Colors.red,
                      ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: SpeedDial(
              icon: Icons.settings,
              activeIcon: Icons.close,
              childPadding: const EdgeInsets.all(5),
              spaceBetweenChildren: 4,
              backgroundColor: Colors.grey[600],
              children: [
                SpeedDialChild(
                    child: const Icon(Icons.cached),
                    label: "更新",
                    onTap: () => getAvailableTypes(),
                    foregroundColor: Colors.grey[800],
                    labelStyle: TextStyle(color: Colors.grey[800])),
                SpeedDialChild(
                    child: const Icon(Icons.key),
                    label: "トークンを登録する",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterKeysPage())),
                    foregroundColor: Colors.grey[800],
                    labelStyle: TextStyle(color: Colors.grey[800]))
              ]),
        ),
        if (_isLoading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (_isLoading)
          Center(
            child: responseStatusIcon(_responseStatus),
          ),
      ],
    );
  }
}
