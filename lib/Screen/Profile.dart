import 'dart:async';
import 'dart:convert';

import 'package:coffee_manager/Screen/BottomNavBar.dart';
import 'package:coffee_manager/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Future<List<Map<String, dynamic>>> retrieveUserOrders(String username) async {
    final db = await openDatabase('coffee.db');
    return await db.rawQuery('SELECT * FROM users');
  }

  Future<void> update(int useCheck, String username) async {
    final db = await openDatabase('coffee.db');
    await db.execute('UPDATE users SET useCheck = ? WHERE username = ?',
        [useCheck, username]);
  }
}

class Profile extends StatefulWidget {
  final String? fullname;
  final String? username;
  const Profile({Key? key, required this.fullname, required this.username})
      : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool useCheck = false;
  DatabaseHelper db = new DatabaseHelper();
  TimeOfDay timenow = TimeOfDay.now();
  String? _timeToDo;
  String? _tinhTrang;
  String? _checkIn;
  bool inTime = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    init();
    fetchCheckTimeCaLam('${timenow.hour}:${timenow.minute}');
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        fetchCheckTimeCaLam('${timenow.hour}:${timenow.minute}');
      });
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void checkTime(String _timeRange, String _checktime) {
    List<String> times = _timeRange.split(" - ");

    String startTime = times[0];
    String endTime = times[1];

    if (isBetween(_checktime, startTime, endTime)) {
      setStateIfMounted(() {
        inTime = true;
      });
    } else {
      setStateIfMounted(() {
        inTime = false;
      });
    }
  }

  bool isBetween(String checkTime, String startTime, String endTime) {
    List<String> checkParts = checkTime.split(":");
    List<String> startParts = startTime.split(":");
    List<String> endParts = endTime.split(":");

    int checkHour = int.parse(checkParts[0]);
    int checkMinute = int.parse(checkParts[1]);

    int startHour = int.parse(startParts[0]);
    int startMinute = int.parse(startParts[1]);

    int endHour = int.parse(endParts[0]);
    int endMinute = int.parse(endParts[1]);

    if (checkHour > startHour && checkHour < endHour) {
      return true;
    } else if (checkHour == startHour && checkMinute >= startMinute) {
      return true;
    } else if (checkHour == endHour && checkMinute <= endMinute) {
      return true;
    }

    return false;
  }

  Future<void> fetchCheckTimeCaLam(String timenow) async {
    bool success = false;
    final response = await http.get(Uri.parse(url +
        "lichlam/checkGioLam.php?timenow=${timenow}&&username=${username}"));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        setStateIfMounted(() {
          _timeToDo = jsonData['time'];
          _tinhTrang = jsonData['tinhtrang'];
          if(_tinhTrang == '0'){
             _checkIn = "Chưa Check In";
          }else if(_tinhTrang == '1'){
            _checkIn = "Đã Check In";
          }else{
             _checkIn = "Đã Check Out";
          }
          checkTime(_timeToDo.toString(), timenow);
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load data'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> init() async {
    List<Map<String, dynamic>> users =
        await db.retrieveUserOrders(username.toString());
    for (var user in users) {
      setState(() {
        user['useCheck'] == 0 ? useCheck = false : useCheck = true;
      });
    }
  }

  Future<void> changeUseCheck(int useCheck) async {
    db.update(useCheck, username.toString());
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(134, 248, 235, 216),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width,
            height: 150,
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: Color(0xFFFFFFFF), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset("images/logo.png", fit: BoxFit.cover),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        fullname.toString(),
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 18,
                          color: Color(0xff000000),
                        ),
                      ),
                      Text(
                        "Nhân viên",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "•",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 40,
                              color: inTime == true ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                              '${(_timeToDo.toString() == 'null') ? "" : _timeToDo.toString()}'),
                        ],
                        
                      ),
                      Text(
                              '${(_checkIn.toString() == 'null') ? "" : _checkIn.toString()}'),

                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: false,
              physics: ScrollPhysics(),
              children: [
                Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: Color(0xFFFFFFFF), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              "Thông tin cá nhân",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xff212435),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/dangkylichlam',
                        arguments: {"username": username});
                  },
                  child: Container(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: Color(0xFFFFFFFF), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                "Đăng ký lịch làm",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                              ),
                            )),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xff212435),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: Color(0xFFFFFFFF), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              "Đăng nhập TouchID / FaceID",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: CupertinoSwitch(
                          value: useCheck,
                          onChanged: (value) {
                            setState(() {
                              useCheck = value;
                              useCheck == true
                                  ? (changeUseCheck(1))
                                  : (changeUseCheck(0));
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
