import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../global.dart';

class TypeProduct {
  final String id;
  final String tenloai;

  TypeProduct({
    required this.id,
    required this.tenloai,
  });
}

class ThemLoaiSP extends StatefulWidget {
  const ThemLoaiSP({Key? key}) : super(key: key);

  @override
  _ThemLoaiSPState createState() => _ThemLoaiSPState();
}

class _ThemLoaiSPState extends State<ThemLoaiSP> {
  List<TypeProduct> _typeProducts = [];
  final TextEditingController _tenLoaiSP = TextEditingController();
  @override
  void initState() {
    super.initState();
    _FetchDataTypeProduct();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<void> _ThemLoaiSanPham(String _tenloai) async {
    final Uri apiUrl = Uri.parse(url + "product/addTypeProduct.php");
    final response = await http.post(
      apiUrl,
      body: {"tenloai": _tenloai},
    );

    if (response.statusCode == 200) {
      String message = "";
      try {
        Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              text: "Thêm Thành Công");
        }
      } on Exception {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: "Có Lỗi Trong Quá Trình Thêm Tên Loại Sản Phẩm");
      }
    } else {
      throw Exception('Failed');
    }
  }

  Future<void> _FetchDataTypeProduct() async {
    final response =
        await http.get(Uri.parse(url + "product/getTypeProduct.php"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setStateIfMounted(() {
        _typeProducts = data
            .map((item) => TypeProduct(
                  id: item['id'],
                  tenloai: item['tenloai'],
                ))
            .toList();
      });
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

  Future<void> _DeleteTypeProduct(String id) async {
    final response = await http
        .delete(Uri.parse(url + "product/addTypeProduct.php?id=${id}"));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: "Thêm Thành Công");
        _FetchDataTypeProduct();
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Thêm Loại Sản Phẩm"),
            centerTitle: true,
            shadowColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 5,
          ),
          backgroundColor: Color.fromARGB(255, 252, 246, 238),
          body: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Tên loại',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(15.0),
                      child: TextField(
                        controller: _tenLoaiSP,
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
                            borderSide:
                                BorderSide(color: Color(0xFFFFFFFF), width: 0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(color: Color(0xFFFFFFFF), width: 0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(color: Color(0xFFFFFFFF), width: 0),
                          ),
                          hintText: "Tên loại sản phẩm",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Color(0xFFFFFFFF),
                          isDense: false,
                          contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 20),
                      child: MaterialButton(
                        onPressed: () {
                          _ThemLoaiSanPham(_tenLoaiSP.text);
                        },
                        color: Color(0xFF4B2C20),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          side: BorderSide(color: Color(0xFF4B2C20), width: 1),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          "Thêm",
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
                    for (final type in _typeProducts)
                      Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xffffffff),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 4,
                              offset: Offset(1, 2), // Shadow position
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      type.tenloai,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 16,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                                child: InkWell(
                                  onTap: () async {
                                    if (await confirm(
                                      context,
                                      title: const Text('Xác nhận'),
                                      content: const Text(
                                          'Bạn có chắc chắn muốn xoá?'),
                                      textOK: const Text('Xoá'),
                                      textCancel: const Text('Huỷ'),
                                    )) {
                                      _DeleteTypeProduct(type.id);
                                    }
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Color(0xff212435),
                                    size: 24,
                                  ),
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
