import 'dart:async';
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
      required this.fullname});
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

class LichLamViec extends StatefulWidget {
  const LichLamViec({Key? key}) : super(key: key);

  @override
  _LichLamViecState createState() => _LichLamViecState();
}

class _LichLamViecState extends State<LichLamViec> {
  DateTime? _selectedDate;
  TimeOfDay selectedTime_1 = TimeOfDay.now();
  TimeOfDay selectedTime_2 = TimeOfDay.now();
  DateTime dt = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<LichLam> _lichLam = [];
  final TextEditingController _textEditingController = TextEditingController();
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    fetchCaLamViec(removeTime(dt.toString()));
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        fetchCaLamViec(removeTime(dt.toString()));
      });
    });
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

  Future<void> _ThemCaLam(String ngay, String soluong, String ca) async {
    try {
      final response = await http.post(Uri.parse(url + 'lichlam/lichlam.php'),
          body: {"ngay": ngay, "soluong": soluong, "ca": ca});
      if (response.statusCode == 200) {
        try {
          Navigator.pop(context);
          Map<String, dynamic> jsonData = json.decode(response.body);
          QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              text: "Tạo ca làm thành công");
          fetchCaLamViec(removeTime(dt.toString()));
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

  Future<void> showInformationDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          bool isChecked = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Ngày : ${convertDateTime(_selectedDate.toString())}'),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Ca : ${selectedTime_1.hour}:${selectedTime_1.minute} - ${selectedTime_2.hour}:${selectedTime_2.minute}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                final TimeOfDay? timeOfDay_1 =
                                    await showTimePicker(
                                        context: context,
                                        initialTime: selectedTime_1,
                                        initialEntryMode:
                                            TimePickerEntryMode.dial);
                                if (timeOfDay_1 != null) {
                                  setState(() {
                                    selectedTime_1 = timeOfDay_1;
                                  });
                                }
                              },
                              child: Text('Giờ bắt đầu')),
                          ElevatedButton(
                              onPressed: () async {
                                final TimeOfDay? timeOfDay_2 =
                                    await showTimePicker(
                                        context: context,
                                        initialTime: selectedTime_2,
                                        initialEntryMode:
                                            TimePickerEntryMode.dial);
                                if (timeOfDay_2 != null) {
                                  setState(() {
                                    selectedTime_2 = timeOfDay_2;
                                  });
                                }
                              },
                              child: Text('Giờ kết thúc')),
                        ],
                      ),
                      Text(
                        'Số lượng :',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _textEditingController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : "Nhập số lượng";
                        },
                        decoration: InputDecoration(hintText: "Nhập số lượng"),
                      ),
                    ],
                  )),
              title: Text(
                'Thêm ca làm',
              ),
              actions: <Widget>[
                InkWell(
                  child: Text('Thêm'),
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      // Do something like updating SharedPreferences or User Settings etc.
                      _ThemCaLam(
                          _selectedDate.toString(),
                          _textEditingController.text,
                          '${selectedTime_1.hour}:${selectedTime_1.minute} - ${selectedTime_2.hour}:${selectedTime_2.minute}');
                    }
                  },
                ),
              ],
            );
          });
        });
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
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDays = _getCurrentWeek();
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
                      InkWell(
                        onTap: () async {
                          if (_selectedDate == null) {
                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                text: "Vui lòng chọn ngày cần thêm");
                          } else {
                            await showInformationDialog(context);
                          }
                        },
                        child: Icon(FontAwesomeIcons.add),
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
                                ElevatedButton(
                                    onPressed: () {
                                      _HuyCaLam(ll.id);
                                      fetchCaLamViec(removeTime(dt.toString()));
                                    },
                                    child: Text('Huỷ')),
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
