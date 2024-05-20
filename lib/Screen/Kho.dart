///File download from FlutterViz- Drag and drop a tools. For more details visit https://flutterviz.io/
import 'dart:convert';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:coffee_manager/global.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class Product {
  final String id;
  final String ten;
  final String image;
  final String gia;
  final String loai;
  final String soluong;

  Product(
      {required this.id,
      required this.ten,
      required this.image,
      required this.gia,
      required this.loai,
      required this.soluong});
}

String convertToCurrencyFormat(String input) {
  final numberFormat = NumberFormat("#,##0.###", "vi_VN");
  final number = int.parse(input);
  return numberFormat.format(number);
}

class Kho extends StatefulWidget {
  const Kho({Key? key}) : super(key: key);

  @override
  _KhoState createState() => _KhoState();
}

class _KhoState extends State<Kho> {
  List<Product> _products = [];
  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<void> deleteProduct(String id) async {
    final response =
        await http.delete(Uri.parse(url + "product/products.php?id=$id"));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) {
        fetchProducts();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: "Xoá thành công");
      }
    }
  }

  Future<void> fetchProducts() async {
    bool success = false;
    final response = await http.get(Uri.parse(url + "product/products.php"));

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
          _products = data
              .map((item) => Product(
                    id: item['id'],
                    ten: item['ten'],
                    image: item['image'],
                    gia: item['gia'],
                    loai: item['loai'],
                    soluong: item['soluong'],
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kho Hàng"),
        centerTitle: true,
        shadowColor: Colors.grey,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/themsanpham');
      //   },

      //   child: Icon(Icons.add),
      //   foregroundColor: Colors.white,
      //   backgroundColor: Color.fromARGB(188, 75, 44, 32), //<-- SEE HERE
      // ),
      floatingActionButton: SpeedDial(
        backgroundColor: Color.fromARGB(188, 75, 44, 32),
        child: Icon(
          FontAwesomeIcons.add,
          color: Colors.white,
        ),
        children: [
          SpeedDialChild(
            child: Icon(FontAwesomeIcons.add),
            label: 'Thêm sản phẩm',
            onTap: () {
              Navigator.pushNamed(context, '/themsanpham');
            },
          ),
          SpeedDialChild(
            child: Icon(FontAwesomeIcons.add),
            label: 'Thêm loại sản phẩm',
            onTap: () {
              Navigator.pushNamed(context, '/themloaisp');
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(134, 248, 235, 216),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 50),
                child: Material(
                  borderRadius: BorderRadius.circular(15.0),
                  elevation: 10,
                  child: TextField(
                    controller: TextEditingController(),
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
                        borderSide:
                            BorderSide(color: Color(0xffffffff), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide:
                            BorderSide(color: Color(0xffffffff), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide:
                            BorderSide(color: Color(0xffffffff), width: 1),
                      ),
                      hintText: "Tìm kiếm",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Color(0x7e000000),
                      ),
                      filled: true,
                      fillColor: Color(0xffffffff),
                      isDense: false,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      suffixIcon: Icon(Icons.youtube_searched_for,
                          color: Color(0xff212435), size: 24),
                    ),
                  ),
                )),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Tên đơn vị",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Chức năng",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xffff0000),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (final product in _products)
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
                              product.ten,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 16,
                                color: Color(0xff000000),
                              ),
                            ),
                            Text(
                              "Giá : ${convertToCurrencyFormat(product.gia)} VNĐ | Số lượng : ${product.soluong}",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Icon(
                        Icons.edit,
                        color: Color(0xff212435),
                        size: 24,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        QuickAlert.show(
                          title: "Xoá sản phẩm",
                          context: context,
                          type: QuickAlertType.confirm,
                          text: 'Xác nhận xoá',
                          confirmBtnText: 'Yes',
                          onConfirmBtnTap: () {
                            deleteProduct(product.id);
                            Navigator.pop(context);
                          },
                          cancelBtnText: 'No',
                          onCancelBtnTap: () {
                            Navigator.pop(context);
                          },
                          confirmBtnColor: Colors.green,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: Icon(
                          Icons.delete,
                          color: Color(0xff212435),
                          size: 24,
                        ),
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
