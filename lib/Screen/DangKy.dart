import 'dart:convert';

import 'package:coffee_manager/global.dart';
import 'package:coffee_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Database? _database;
  
  void insertData(String username ) async {
      Map<String, dynamic> row = {
        'username'  : username,
        'useCheck' : 0
      };
      final db = await openDatabase('coffee.db');
      await db.insert('users', row);
    }
}

class DangKyWidget extends StatefulWidget {
  const DangKyWidget({Key? key}) : super(key: key);

  @override
  _DangKyWidgetState createState() => _DangKyWidgetState();
}

class _DangKyWidgetState extends State<DangKyWidget> {
  bool _passwordVisible = false;
  bool _reverse = false;
  String _password = "";
  bool readOnly = true;
  bool _samePassword = true;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passWordController = TextEditingController();
  final TextEditingController rePassWordController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  Future<void> _DangKy() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
    final Uri apiUrl = Uri.parse(url + "log/signup.php");
    String username = userNameController.text;
    String fullname = fullNameController.text;
    String password = passWordController.text;
    try {
      final response = await http.post(
        apiUrl,
        body: jsonEncode(
            {"username": username, "password": password, "fullname": fullname}),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> jsonData = json.decode(response.body);
          if (jsonData['message'] == "success") {
            DatabaseHelper dbHelper = DatabaseHelper();
            
            dbHelper.insertData(username);

            Navigator.pushNamed(context, "/");
            QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                text: "Đăng Ký Thành Công");
          } else {
            QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                text: "Đăng Ký Thất Bại");
            Navigator.pop(context);
          }
        } on Exception {}
      } else {
        Navigator.pop(context);
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: "Vui lòng kiểm tra kết nối mạng");
      }
    } on Exception {
      Navigator.pop(context);
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Vui lòng kiểm tra kết nối mạng");
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    userNameController.dispose();
    passWordController.dispose();
    rePassWordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
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
                  Navigator.pushNamed(context, '/');
                },
                color: Color(0xffffffff),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  side: BorderSide(color: Color(0xff4B2C20), width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Đăng nhập ngay",
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
        backgroundColor: Color(0XFFF8EBD8),
        body: SafeArea(
          top: true,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                            child: Align(
                              alignment: Alignment.center,
                              child: Image(
                                image: AssetImage("images/logo.png"),
                                height: 100,
                                width: 100,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Text(
                            "Họ và tên",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 00),
                              child: Material(
                                borderRadius: BorderRadius.circular(15.0),
                                elevation: 5,
                                shadowColor: Colors.grey,
                                child: TextField(
                                  controller: fullNameController,
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
                                    hintText: "Họ và tên",
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
                          Text(
                            "Tài khoản",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 00),
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
                                    color: Colors.black,
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
                          Text(
                            "Mật khẩu",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 00),
                              child: Material(
                                borderRadius: BorderRadius.circular(15.0),
                                elevation: 5,
                                shadowColor: Colors.grey,
                                child: TextField(
                                  onChanged: (val) {
                                    if (val.length < 6) {
                                      readOnly = true;
                                    } else {
                                      setState(() {
                                        _password = val;
                                        readOnly = false;
                                      });
                                    }
                                  },
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
                                        // Based on passwordVisible state choose the icon
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        // Update the state i.e. toogle the state of passwordVisible variable
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              )),
                          readOnly
                              ? Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
                                  child: Text(
                                    "Mật khẩu phải có ít nhất 6 ký tự",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14,
                                      color: Color(0xff000000),
                                    ),
                                  ),
                                )
                              : Text(
                                  "Nhập lại mật khẩu",
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Color(0xff000000),
                                  ),
                                ),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 00),
                              child: Material(
                                borderRadius: BorderRadius.circular(15.0),
                                elevation: 5,
                                shadowColor: Colors.grey,
                                child: TextField(
                                  onChanged: (val) {
                                    if (val == _password) {
                                      setState(() {
                                        _samePassword = true;
                                      });
                                    } else {
                                      setState(() {
                                        _samePassword = false;
                                      });
                                    }
                                  },
                                  controller: rePassWordController,
                                  obscureText: !_passwordVisible,
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  readOnly: readOnly,
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
                                          color: _samePassword
                                              ? Color(0x00000000)
                                              : Colors.red,
                                          width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: BorderSide(
                                          color: _samePassword
                                              ? Color(0x00000000)
                                              : Colors.red,
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: BorderSide(
                                          color: _samePassword
                                              ? Color(0x00000000)
                                              : Colors.red,
                                          width: 1),
                                    ),
                                    hintText: "Nhập lại mật khẩu",
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
                                        // Based on passwordVisible state choose the icon
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        // Update the state i.e. toogle the state of passwordVisible variable
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              )),
                          _samePassword
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
                                  child: Text(
                                    "Mật khẩu chưa trùng",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: MaterialButton(
                              onPressed: () {
                                _samePassword ? _DangKy() : null;
                              },
                              color: Color(0xFF4B2C20),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                side: BorderSide(
                                    color: Color(0xFF4B2C20), width: 1),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                "Đăng ký",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              textColor: Color(0xffffffff),
                              height: 50,
                              minWidth: MediaQuery.of(context).size.height,
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Align(
                                child: Text(
                                  "Bạn đã có tài khoản ?",
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Color(0xff000000),
                                  ),
                                ),
                              ))
                        ],
                      ),
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
