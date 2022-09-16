import 'package:flutter/material.dart';
import 'package:freee_time_stamp/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterKeysPage extends StatefulWidget {
  const RegisterKeysPage({super.key});

  @override
  State<RegisterKeysPage> createState() => _RegisterKeysPage();
}

class _RegisterKeysPage extends State<RegisterKeysPage> {
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              title: const Text("トークンを登録する"),
            ),
            body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Access Token',
                            ),
                            initialValue: _accessToken,
                            onChanged: (value) => {
                              setState(() {
                                _accessToken = value;
                              })
                            },
                          ),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Refresh Token',
                            ),
                            initialValue: _refreshToken,
                            onChanged: (value) => {
                              setState(() {
                                _refreshToken = value;
                              })
                            },
                          ),
                        )),
                    EnableButton(text: '登録', onPressed: () => setTokens())
                  ]),
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
