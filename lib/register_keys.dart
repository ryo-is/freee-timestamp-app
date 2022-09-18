import 'package:flutter/material.dart';
import 'package:freee_time_stamp/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './main.dart';

class RegisterKeysPage extends StatefulWidget {
  const RegisterKeysPage({super.key});

  @override
  State<RegisterKeysPage> createState() => _RegisterKeysPage();
}

class _RegisterKeysPage extends State<RegisterKeysPage> with RouteAware {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String _accessToken = '';
  String _refreshToken = '';
  bool _isLoading = false;

  void startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void finishLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> setTokens() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('accessToken', _accessToken);
    await prefs.setString('refreshToken', _refreshToken);
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
  void didPush() {
    _prefs.then((SharedPreferences prefs) {
      setState(() {
        _accessToken = prefs.getString('accessToken') ?? '';
        _refreshToken = prefs.getString('refreshToken') ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              title: const Text("トークンを登録する"),
            ),
            body: Center(
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Access Token',
                                ),
                                initialValue: '',
                                onChanged: (value) => {
                                  setState(() {
                                    _accessToken = value;
                                  })
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _accessToken,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                            ]),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Refresh Token',
                                ),
                                initialValue: '',
                                onChanged: (value) => {
                                  setState(() {
                                    _refreshToken = value;
                                  })
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _refreshToken,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                            ]),
                      ),
                      EnableButton(text: '登録', onPressed: () => setTokens())
                    ],
                  )),
            )),
        if (_isLoading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
