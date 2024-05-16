import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coffee_manager/Screen/BottomNavBar.dart';
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

String? _username;

class NhanVien {
  final String username;
  final String fullname;
  final String luong;

  NhanVien(
      {required this.username, required this.fullname, required this.luong});
}

class QuanLyNhanVien extends StatefulWidget {
  const QuanLyNhanVien({Key? key}) : super(key: key);

  @override
  _QuanLyNhanVienState createState() => _QuanLyNhanVienState();
}

class _QuanLyNhanVienState extends State<QuanLyNhanVien> {
  DateTime? _selectedDate;
  TimeOfDay selectedTime_1 = TimeOfDay.now();
  TimeOfDay selectedTime_2 = TimeOfDay.now();
  DateTime dt = DateTime.now();
  List<NhanVien> _nhanViens = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<void> fetchProducts() async {
    bool success = false;
    final response = await http.get(Uri.parse(url + "nhanvien/nhanvien.php?all"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      for (var item in data) {
        setStateIfMounted(() {
          success = item['success'] ?? true;
        });
      }
      if (success == false) {
      } else {
        setStateIfMounted(() {
          _nhanViens = data
              .map((item) => NhanVien(
                    username: item['username'],
                    fullname: item['fullname'],
                    luong: item['luong'],
                  ))
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text('Quản Lý Nhân Viên'),
              centerTitle: true,
              shadowColor: Colors.grey,
              backgroundColor: Colors.white,
              elevation: 5,
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  for (final nv in _nhanViens)
                    InkWell(
                      onTap: (){
                        Navigator.pushNamed(context, '/thongtinnhanvien', arguments: {"username" : nv.username});
                      },
                      child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 5, left: 10, right: 10, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Họ và tên : ${nv.fullname}'),
                                Text('Mức lương : ${nv.luong}đ / h'),
                                Text('Tình trạng : Free')
                              ],
                            ),
                          )),
                    ),
                    ),
                ],
              ),
            )));
  }
}
