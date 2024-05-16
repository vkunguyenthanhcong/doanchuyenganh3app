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

class ThongTinNhanVien extends StatefulWidget {
  const ThongTinNhanVien({Key? key}) : super(key: key);

  @override
  _ThongTinNhanVienState createState() => _ThongTinNhanVienState();
}

class _ThongTinNhanVienState extends State<ThongTinNhanVien> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController luongController = TextEditingController();
  final TextEditingController luongThangController = TextEditingController();
  String _selectedRole = '';
  String? fullName;
  String? luong;
  bool isLoading = true;
  String? tongluong;
  @override
  void initState() {
    super.initState();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<void> _FetchThongTin(String username) async {
    try {
      final response = await http.get(
        Uri.parse(url + 'nhanvien/nhanvien.php?username=${username}'),
      );
      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> jsonData = json.decode(response.body);
          if (jsonData['success'] == true) {
            setStateIfMounted(() {
              fullName = jsonData['fullname'];
              tongluong = jsonData['tongluong'];

              tongluong == null
                  ? luongThangController.text = "0"
                  : luongThangController.text = tongluong.toString();
              fullNameController.text = fullName.toString();
              luong = jsonData['luong'];
              luongController.text = luong.toString();
              if (jsonData['roll'] == '0') {
                _selectedRole = "Người mới";
              } else if (jsonData['roll'] == '1') {
                _selectedRole = "Nhân viên";
              } else {
                _selectedRole = "Quản lý";
              }
              isLoading = false;
            });
          }
        } on Exception {}
      } else {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: "Vui lòng kiểm tra kết nối mạng");
      }
    } on Exception {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Vui lòng kiểm tra kết nối mạng");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setStateIfMounted(() {
      isLoading = true;
      _FetchThongTin(data['username']);
    });
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text('Thông Tin Nhân Viên'),
              centerTitle: true,
              shadowColor: Colors.grey,
              backgroundColor: Colors.white,
              elevation: 5,
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Họ và tên'),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 00),
                      child: Material(
                        borderRadius: BorderRadius.circular(15.0),
                        elevation: 5,
                        shadowColor: Colors.grey,
                        child: TextField(
                          readOnly: true,
                          obscureText: false,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          controller: fullNameController,
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
                            hintText: "0",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff989898),
                            ),
                            filled: true,
                            fillColor: Color(0xffFFFFFF),
                            isDense: false,
                            contentPadding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                          ),
                        ),
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  Text('Mức lương / Giờ'),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 00),
                      child: Material(
                        borderRadius: BorderRadius.circular(15.0),
                        elevation: 5,
                        shadowColor: Colors.grey,
                        child: TextField(
                          controller: luongController,
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
                            hintText: "0",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff989898),
                            ),
                            filled: true,
                            fillColor: Color(0xffFFFFFF),
                            isDense: false,
                            contentPadding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                          ),
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Lương trong tháng'),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 00),
                      child: Material(
                        borderRadius: BorderRadius.circular(15.0),
                        elevation: 5,
                        shadowColor: Colors.grey,
                        child: TextField(
                          readOnly: true,
                          obscureText: false,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          controller: luongThangController,
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
                            hintText: "0",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff989898),
                            ),
                            filled: true,
                            fillColor: Color(0xffFFFFFF),
                            isDense: false,
                            contentPadding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                          ),
                        ),
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  Text('Chức vụ'),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 00),
                      child: Column(
                        children: [
                          RadioListTile(
                            title: Text('Người mới'),
                            value: 'Người mới',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                          RadioListTile(
                            title: Text('Nhân viên'),
                            value: 'Nhân viên',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                          RadioListTile(
                            title: Text('Quản lý'),
                            value: 'Quản lý',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                        ],
                      )),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: MaterialButton(
                      onPressed: () {},
                      color: Color(0xFF4B2C20),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: BorderSide(color: Color(0xFF4B2C20), width: 1),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        "Cập nhật",
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
                ],
              ),
            )));
  }
}
