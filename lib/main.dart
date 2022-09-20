import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:freee_time_stamp/register_keys.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'buttons.dart';
import 'enums.dart';

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
  TimeClock _timeClock =
      TimeClock(type: 'none', typeString: 'まだ打刻していません', datetime: '');
  String _accessToken = '';
  String _refreshToken = '';
  String _employeeId = '';
  String _companyId = '';
  String _clientId = '';
  String _clientSecret = '';

  bool _isLoading = false;
  ResponseStatus _responseStatus = ResponseStatus.loading;

  String convertAvailableTypeToString(String type) {
    switch (type) {
      case ('clock_in'):
        return '勤務中';
      case ('break_begin'):
        return '休憩中';
      case ('break_end'):
        return '勤務中';
      case ('clock_out'):
        return '退勤済';
      default:
        return 'まだ打刻していません';
    }
  }

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

  Future<bool> apiWrapper(Function function, dynamic arg) async {
    startLoading();

    if (_accessToken == '') {
      finishLoading(ResponseStatus.error);
      showErrorDialog('アクセストークンを登録してください');
      return false;
    }

    ResponseObject refreshTokenResponse = await refreshAccessToken();
    if (!refreshTokenResponse.ok) {
      finishLoading(ResponseStatus.error);
      showErrorDialog(refreshTokenResponse.message);
      return false;
    }

    ResponseObject res = (arg != null) ? await function(arg) : await function();
    if (!res.ok) {
      finishLoading(ResponseStatus.error);
      showErrorDialog(res.message);
      return false;
    }

    finishLoading(ResponseStatus.success);
    return true;
  }

  Future<ResponseObject> getAvailableTypes() async {
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

      ResponseObject res = await getTimeClocks();
      if (!res.ok) {
        return ResponseObject(ok: false, message: res.message);
      }
    } else {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorDescription = jsonResponse['error_description'] as String;
      return ResponseObject(ok: false, message: errorDescription);
    }

    return ResponseObject(ok: true, message: '');
  }

  Future<ResponseObject> getTimeClocks() async {
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
        DateTime datetime = DateTime.parse(lastTimeClock['datetime'])
            .add(const Duration(hours: 9));
        String formatDate = formatter.format(datetime);
        String type = lastTimeClock['type'];
        TimeClock timeClock = TimeClock(
            type: type,
            typeString: convertAvailableTypeToString(lastTimeClock['type']),
            datetime: formatDate);
        setState(() {
          _timeClock = timeClock;
        });
      }
    } else {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorDescription = jsonResponse['error_description'] as String;
      return ResponseObject(ok: false, message: errorDescription);
    }

    return ResponseObject(ok: true, message: '');
  }

  Future<ResponseObject> registerTimeClock(AvailableType type) async {
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
      ResponseObject res = await getAvailableTypes();
      if (!res.ok) {
        return ResponseObject(ok: false, message: res.message);
      }
    } else {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorDescription = jsonResponse['error_description'] as String;
      return ResponseObject(ok: false, message: errorDescription);
    }

    return ResponseObject(ok: true, message: '');
  }

  Future<ResponseObject> refreshAccessToken() async {
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
      return ResponseObject(ok: true, message: '');
    } else {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorDescription = jsonResponse['error_description'] as String;
      return ResponseObject(ok: false, message: errorDescription);
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

      apiWrapper(getAvailableTypes, null);
      return;
    });
  }

  @override
  void initState() {
    super.initState();

    try {
      init();
    } catch (e) {
      throw Error();
    }
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
                    const Text(
                      '現在のステータス',
                      style: TextStyle(fontSize: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        _timeClock.typeString,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_availableTypes
                        .where((element) => element == 'clock_in')
                        .isNotEmpty)
                      EnableButton(
                        text: '出勤する',
                        onPressed: () => apiWrapper(
                            registerTimeClock, AvailableType.clockIn),
                      ),
                    if (_availableTypes
                        .where((element) => element == 'break_begin')
                        .isNotEmpty)
                      EnableButton(
                        text: '休憩開始',
                        onPressed: () => apiWrapper(
                            registerTimeClock, AvailableType.breakBegin),
                        color: Colors.green,
                      ),
                    if (_availableTypes
                        .where((element) => element == 'break_end')
                        .isNotEmpty)
                      EnableButton(
                        text: '休憩終了',
                        onPressed: () => apiWrapper(
                            registerTimeClock, AvailableType.breakEnd),
                        color: Colors.green,
                      ),
                    if (_availableTypes
                            .where((element) => element == 'clock_out')
                            .isNotEmpty &&
                        _timeClock.type != 'clock_out')
                      EnableButton(
                        text: '退勤する',
                        onPressed: () => apiWrapper(
                            registerTimeClock, AvailableType.clockOut),
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
                    onTap: () => apiWrapper(getAvailableTypes, null),
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
