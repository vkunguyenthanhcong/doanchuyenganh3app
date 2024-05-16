import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:coffee_manager/Screen/Order.dart';
import 'package:coffee_manager/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

class LichLam {
  final String id;
  final String ngay;
  final String ca;
  final String soluong;
  final String dadangky;
  final String nhanvien;
final String fullname;
  LichLam(
      {required this.id,
      required this.ngay,
      required this.ca,
      required this.soluong,
      required this.dadangky,
      required this.nhanvien,
      required this.fullname
      });
}

String? _username;
int calculate(String nhanvienString) {
  List<String> nhanvienArray = nhanvienString.split(', ');
  int nhanvienCount = nhanvienArray.length;
  return nhanvienCount;
}

String convertToCurrencyFormat(String input) {
  final numberFormat = NumberFormat("#,##0.###", "vi_VN");
  final number = int.parse(input);
  return numberFormat.format(number);
}

String convertDateTime(String datetime) {
  if (datetime != null || datetime != "null") {
    DateTime dateTime = DateTime.parse(datetime);
    String formattedDateTime = DateFormat('dd-MM-yyyy').format(dateTime);
    return formattedDateTime;
  } else {
    return '';
  }
}

String removeTime(String datetime) {
  if (datetime != null || datetime != "null") {
    DateTime dateTime = DateTime.parse(datetime);
    String formattedDateTime = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDateTime;
  } else {
    return '';
  }
}

class DangKyLichLam extends StatefulWidget {
  const DangKyLichLam({Key? key}) : super(key: key);

  @override
  _DangKyLichLamState createState() => _DangKyLichLamState();
}

class _DangKyLichLamState extends State<DangKyLichLam> {
  DateTime? _selectedDate;
  TimeOfDay selectedTime_1 = TimeOfDay.now();
  TimeOfDay selectedTime_2 = TimeOfDay.now();
  DateTime dt = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<LichLam> _lichLam = [];
  final TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchCaLamViec(removeTime(dt.toString()));
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<void> fetchCaLamViec(String datetimenow) async {
    bool success = false;
    final response = await http.get(Uri.parse(url + "lichlam/lichlam.php"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      for (var item in data) {
        setStateIfMounted(() {
          success = item['success'] ?? true;
        });
      }
      if (success == false) {
        _lichLam = [];
      } else {
        setStateIfMounted(() {
          _lichLam = data
              .map((item) => LichLam(
                    id: item['id'],
                    ngay: item['ngay'],
                    ca: item['ca'],
                    soluong: item['soluong'],
                    dadangky: item['dadangky'],
                    nhanvien: item['nhanvien'] == null ? "" : item['nhanvien'],
                    fullname: item['fullname'] == null ? "" : item['fullname'],
                  ))
              .toList();
          _lichLam = _lichLam
              .where((item) => item.ngay == datetimenow.toString())
              .toList();
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load products'),
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

  Future<void> _HuyCaLam(String id) async {
    try {
      final response = await http.delete(
        Uri.parse(url + 'lichlam/lichlam.php?id=${id}'),
      );
      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> jsonData = json.decode(response.body);
          fetchCaLamViec(removeTime(dt.toString()));
          Navigator.pop(context);
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

  Future<void> _DangKyCaLam(String username, String idca) async {
    try {
      final response = await http.post(
          Uri.parse(url + 'lichlam/DangKyCaLam.php'),
          body: {"username": username, "idca": idca});
      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> jsonData = json.decode(response.body);
          if (jsonData['success'] == false) {
            QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                text: "Ca làm đã đủ số lượng");
          } else {
            fetchCaLamViec(removeTime(dt.toString()));
            QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                text: "Đăng ký thành công");
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

  List<DateTime> _getCurrentWeek() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;

    // Lấy ngày đầu tuần (thứ Hai)
    DateTime startOfWeek = now.subtract(Duration(days: currentWeekday - 1));

    // Tạo danh sách các ngày trong tuần
    return List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDays = _getCurrentWeek();
    final Map<String, dynamic> data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setStateIfMounted(() {
      _username = data['username'];
    });
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text('Lịch Làm Việc'),
              centerTitle: true,
              shadowColor: Colors.grey,
              backgroundColor: Colors.white,
              elevation: 5,
            ),
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 70,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: weekDays.length,
                    itemBuilder: (context, index) {
                      DateTime day = weekDays[index];
                      String dayOfWeek = DateFormat('E')
                          .format(day); // Day of the week (Mon, Tue, ...)
                      String dayOfMonth = DateFormat('d')
                          .format(day); // Day of the month (1, 2, ...)

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate =
                                DateTime(day.year, day.month, day.day);
                            fetchCaLamViec(
                                removeTime(_selectedDate.toString()));
                          });
                        },
                        child: Card(
                          color: _selectedDate == null
                              ? removeTime(dt.toString()) ==
                                      removeTime(day.toString())
                                  ? Colors.blue
                                  : Colors.white
                              : removeTime(_selectedDate.toString()) ==
                                      removeTime(day.toString())
                                  ? Colors.blue
                                  : Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayOfWeek,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedDate == null
                                      ? removeTime(dt.toString()) ==
                                              removeTime(day.toString())
                                          ? Colors.white
                                          : Colors.black
                                      : removeTime(_selectedDate.toString()) ==
                                              removeTime(day.toString())
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                              Text(
                                dayOfMonth,
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? removeTime(dt.toString()) ==
                                              removeTime(day.toString())
                                          ? Colors.white
                                          : Colors.black
                                      : removeTime(_selectedDate.toString()) ==
                                              removeTime(day.toString())
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Lịch làm việc',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final ll in _lichLam)
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${ll.ca}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      Text('Nhân viên : ${ll.fullname}')
                                    ],
                                  ),
                                ),
                                (ll.nhanvien.contains(_username.toString()) ==
                                        true)
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green),
                                        onPressed: () {},
                                        child: Text(
                                          'Đã đăng ký',
                                          style: TextStyle(color: Colors.white),
                                        ))
                                    : ((calculate(ll.nhanvien) <
                                            int.parse(ll.soluong))
                                        ? ElevatedButton(
                                            onPressed: () {
                                              _DangKyCaLam(
                                                  _username.toString(), ll.id);
                                            },
                                            child: Text('Đăng ký'))
                                        : ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            onPressed: () {},
                                            child: Text(
                                              'Đã đủ',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )))
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            )));
  }
}
