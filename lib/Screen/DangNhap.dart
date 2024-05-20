import 'dart:convert';
import 'dart:math';

import 'package:coffee_manager/global.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sqflite/sqflite.dart';

class DangNhapWidget extends StatefulWidget {
  const DangNhapWidget({Key? key}) : super(key: key);

  @override
  _DangNhapWidgetState createState() => _DangNhapWidgetState();
}

class DatabaseHelper {
  Future<void> createTable() async {
    try {
      final db = await openDatabase('coffee.db');
      await db.execute(
        'CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, useCheck INTEGER)',
      );
    } catch (e) {
      print('Error creating table: $e');
    }
  }

  Future<void> insert(String username, int useCheck) async {
    try {
      final db = await openDatabase('coffee.db');
      await db.execute(
          'INSERT INTO users (username, useCheck) VALUES (?, ?)',
          [username, useCheck]);
    } catch (e) {
      print('Error inserting user: $e');
    }
  }

  Future<List<Map<String, dynamic>>> checkUser() async {
    try {
      final db = await openDatabase('coffee.db');
      return await db.rawQuery('SELECT * FROM users');
    } catch (e) {
      print('Error checking user: $e');
      return [];
    }
  }
}

class _DangNhapWidgetState extends State<DangNhapWidget> {
  bool _passwordVisible = false;
  bool useCheck = false;
  String? username;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passWordController = TextEditingController();
  late SharedPreferences logindata;
  late DatabaseHelper db;

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    init();
  }

  Future<void> init() async {
    await db.createTable();
    List<Map<String, dynamic>> users = await db.checkUser();
    for (final user in users) {
      if (user['username'] == "") {
        // No username saved, show login form
      } else {
        setState(() {
          username = user['username'];
        });
        setState(() {
          useCheck = user['useCheck'] == 1;
        });
      }
    }
  }

  Future<void> insertNewUser() async {
    await db.insert(userNameController.text, 0);
  }

  void showBiometricDialog() async {
    final LocalAuthentication _localAuthentication = LocalAuthentication();
    bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
    print('Biometrics supported: $canCheckBiometrics');
    if (canCheckBiometrics) {
      List<BiometricType> availableBiometrics =
          await _localAuthentication.getAvailableBiometrics();
      print('Available biometrics: $availableBiometrics');
      try {
         bool isAuthenticated = await _localAuthentication.authenticate(
          localizedReason: 'Authenticate to access the app',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
            useErrorDialogs: true,
          ));
        if (isAuthenticated) {
          getData();
        } else {
          print('Biometric authentication failed');
        }
      } catch (e) {
        print('Error during biometric authentication: $e');
      }
    }
  }

  Future<void> getData() async {
    final response =
        await http.get(Uri.parse(url + "log/login.php?username=${username}"));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        passWordController.text = jsonResponse['password'];
      });
      _dangNhap(username.toString());
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  }

  Future<void> _dangNhap(String _username) async {
    SharedPreferences.setMockInitialValues({});
    logindata = await SharedPreferences.getInstance();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
    String username = _username;
    String password = passWordController.text;
    try {
      final response = await http.post(
        Uri.parse(url + 'log/login.php'),
        body: {
          'username': username,
          'password': passWordController.text,
        },
      );
      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> jsonData = json.decode(response.body);
          print(jsonData['roll']);
          if (jsonData['success'] == true) {
            if (jsonData['roll'] == '0') {
              Navigator.pop(context);
              QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  text: "Bạn không phải nhân viên chính thức");
            } else {
              logindata.setString('fullname', jsonData['fullname']);
              logindata.setString('username', username);
              Navigator.pushNamed(context, '/trangchu');
            }
          } else {
            QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                text: "Tài khoản hoặc mật khẩu sái");
            Navigator.pop(context);
          }
        } on Exception catch (e) {
          print(e);
        }
      }
    } on Exception catch (e) {
      Navigator.pop(context);
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Vui lòng kiểm tra kết nối mạng");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        bottomNavigationBar: Container(
          height: 100,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 50),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/dangky');
                },
                color: Color(0xffffffff),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  side: BorderSide(color: Color(0xff4B2C20), width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Tạo tài khoản mới",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                textColor: Color(0xff000000),
                height: 50,
                minWidth: MediaQuery.of(context).size.width,
              ),
            ),
          ),
        ),
        backgroundColor:        Color(0XFFF8EBD8),
        body: SafeArea(
          top: true,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                          child: Image(
                            image: AssetImage("images/logo.png"),
                            height: 100,
                            width: 100,
                            fit: BoxFit.fill,
                          ),
                        ),
                        username != null
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: Text('Xin chào, ${username}')),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        useCheck = false;
                                        username = null;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: FaIcon(
                                            FontAwesomeIcons.arrowsRotate),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Material(
                                  borderRadius: BorderRadius.circular(15.0),
                                  elevation: 5,
                                  shadowColor: Colors.grey,
                                  child: TextField(
                                    controller: userNameController,
                                    obscureText: false,
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14,
                                      color: Color(0xff000000),
                                    ),
                                    decoration: InputDecoration(
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide(
                                            color: Color(0x00000000), width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide(
                                            color: Color(0x00000000), width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide(
                                            color: Color(0x00000000), width: 1),
                                      ),
                                      hintText: "Tài khoản",
                                      hintStyle: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 14,
                                        color: Color(0xff989898),
                                      ),
                                      filled: true,
                                      fillColor: Color(0xffFFFFFF),
                                      isDense: false,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(15, 20, 15, 20),
                                    ),
                                  ),
                                )),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Material(
                              borderRadius: BorderRadius.circular(15.0),
                              elevation: 5,
                              shadowColor: Colors.grey,
                              child: TextField(
                                controller: passWordController,
                                obscureText: !_passwordVisible,
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                                decoration: InputDecoration(
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(
                                        color: Color(0x00000000), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(
                                        color: Color(0x00000000), width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(
                                        color: Color(0x00000000), width: 1),
                                  ),
                                  hintText: "Mật khẩu",
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Color(0xff989898),
                                  ),
                                  filled: true,
                                  fillColor: Color(0xffFFFFFF),
                                  isDense: false,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(15, 20, 15, 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            )),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 10, 0),
                                child: MaterialButton(
                                  onPressed: () {
                                    if (username == null) {
                                      insertNewUser();
                                      _dangNhap(userNameController.text);
                                    } else {
                                      _dangNhap(username.toString());
                                    }
                                  },
                                  color: Color(0xFF4B2C20),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                    side: BorderSide(
                                        color: Color(0xFF4B2C20), width: 1),
                                  ),
                                  child: Text(
                                    "Đăng nhập",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                  textColor: Color(0xffffffff),
                                  height: 50,
                                ),
                              ),
                            ),
                            useCheck == true
                                ? Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20, 20, 0),
                                    child: InkWell(
                                      onTap: () {
                                        showBiometricDialog();
                                      },
                                      child: Material(
                                        elevation: 5,
                                        shadowColor: Colors.grey,
                                        borderRadius: BorderRadius.circular(50),
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: Color(0xFF4B2C20),
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          child: FaIcon(
                                            FontAwesomeIcons.fingerprint,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ))
                                : Container(),
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: Text(
                            "Bạn quên mật khẩu ?",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

