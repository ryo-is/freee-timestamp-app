import 'package:flutter/material.dart';
import 'package:freee_time_stamp/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => UserInfo();
}

class UserInfo extends State<UserInfoPage> with RouteAware {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String _employeeId = '';
  String _companyId = '';
  String _clientId = '';
  String _clientSecret = '';
  String _accessToken = '';
  String _refreshToken = '';

  bool _isEdit = false;

  void saveToSharedPreferences() async {
    SharedPreferences prefs = await _prefs;

    prefs.setString('employeeId', _employeeId);
    prefs.setString('companyId', _companyId);
    prefs.setString('clientId', _clientId);
    prefs.setString('clientSecret', _clientSecret);
    prefs.setString('accessToken', _accessToken);
    prefs.setString('refreshToken', _refreshToken);

    setState(() {
      _isEdit = false;
    });
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
        _employeeId = prefs.getString('employeeId') ?? '';
        _companyId = prefs.getString('companyId') ?? '';
        _clientId = prefs.getString('clientId') ?? '';
        _clientSecret = prefs.getString('clientSecret') ?? '';
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
              title: const Text("ユーザー情報"),
            ),
            body: Center(
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _isEdit
                          ? [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'EmployeeID',
                                      ),
                                      onChanged: (value) => {
                                        setState(() {
                                          _employeeId = value;
                                        })
                                      },
                                    ),
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'CompanyID',
                                      ),
                                      onChanged: (value) => {
                                        setState(() {
                                          _companyId = value;
                                        })
                                      },
                                    ),
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'ClientID',
                                      ),
                                      onChanged: (value) => {
                                        setState(() {
                                          _clientId = value;
                                        })
                                      },
                                    ),
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'ClientSecret',
                                      ),
                                      onChanged: (value) => {
                                        setState(() {
                                          _clientSecret = value;
                                        })
                                      },
                                    ),
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'AccessToken',
                                      ),
                                      onChanged: (value) => {
                                        setState(() {
                                          _accessToken = value;
                                        })
                                      },
                                    ),
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'RefreshToken',
                                      ),
                                      onChanged: (value) => {
                                        setState(() {
                                          _refreshToken = value;
                                        })
                                      },
                                    ),
                                  ]),
                            ]
                          : [
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 1,
                                            color: Colors.grey.shade500))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'EmployeeID',
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 4, left: 8, right: 8),
                                      child: Text(
                                        _employeeId,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 1,
                                            color: Colors.grey.shade500))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'CompanyID',
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 4, left: 8, right: 8),
                                      child: Text(
                                        _companyId,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 1,
                                            color: Colors.grey.shade500))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'ClientID',
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 4, left: 8, right: 8),
                                      child: Text(
                                        _clientId,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 1,
                                            color: Colors.grey.shade500))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'ClientSecret',
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 4, left: 8, right: 8),
                                      child: Text(
                                        _clientSecret,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 1,
                                            color: Colors.grey.shade500))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'AccessToken',
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 4, left: 8, right: 8),
                                      child: Text(
                                        _accessToken,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 1,
                                            color: Colors.grey.shade500))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'RefreshToken',
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 4, left: 8, right: 8),
                                      child: Text(
                                        _refreshToken,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ])),
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: _isEdit ? Colors.green : Colors.blue,
                child:
                    _isEdit ? const Icon(Icons.check) : const Icon(Icons.edit),
                onPressed: () => {
                      if (_isEdit)
                        {saveToSharedPreferences()}
                      else
                        {
                          setState(() {
                            _isEdit = true;
                          })
                        }
                    })),
      ],
    );
  }
}
