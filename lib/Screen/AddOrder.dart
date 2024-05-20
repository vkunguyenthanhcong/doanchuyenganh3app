import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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

class AddOrder extends StatefulWidget {
  const AddOrder({Key? key}) : super(key: key);

  @override
  _AddOrderState createState() => _AddOrderState();
}

String convertToCurrencyFormat(String input) {
  final numberFormat = NumberFormat("#,##0.###", "vi_VN");
  final number = int.parse(input);
  return numberFormat.format(number);
}

class Loai {
  Loai({required this.id, required this.tenloai});

  factory Loai.fromJson(Map<String, dynamic> json) {
    return Loai(
      id: json['id'],
      tenloai: json['tenloai'],
    );
  }

  final String id;
  final String tenloai;
}

String? idban;

class Product {
  Product(
      {required this.id,
      required this.ten,
      required this.image,
      required this.gia,
      required this.loai,
      required this.soluong});

  final String gia;
  final String id;
  final String image;
  final String loai;
  final String soluong;
  final String ten;
}

class _AddOrderState extends State<AddOrder> {
  int value = 0;
  String filterValue = '';
  List<Loai> _loaiList = [];
  List<Product> _products = [];
  List<Product> _filterproducts = [];
  String? _soluong;
  String? _tongtien;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchLoaiList();
    fetchProducts(0);
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<void> fetchProducts(int _loai) async {
    final response = await http.get(Uri.parse(url + "product/products.php"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
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
      if (_loai > 0) {
        _products = _products
            .where((product) => product.loai == _loai.toString())
            .toList();
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

  Future<void> fetchLoaiList() async {
    String jsonData = '[{"id": "0", "tenloai": "Tất cả"}]';
    List<dynamic> data = jsonDecode(jsonData);

    final response =
        await http.get(Uri.parse(url + "product/getTypeProduct.php"));
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        setStateIfMounted(() {
          _loaiList =
              (data + jsonResponse).map((json) => Loai.fromJson(json)).toList();
        });
      } catch (e) {
        print('Failed to decode JSON: $e');
      }
    } else {
      print('Failed to load loai: ${response.statusCode}');
    }
  }

  Future<void> uploadOrder(String idban, String idmon) async {
    try {
      final response =
          await http.post(Uri.parse(url + 'tableorder/addBill.php'), body: {
        'idban': idban,
        'idmon': idmon,
      });
      if (response.statusCode == 200) {
        print(response.body);
        try {
          Map<String, dynamic> jsonData = json.decode(response.body);

          if (jsonData['success'] == false) {
            QuickAlert.show(
                context: context,
                type: QuickAlertType.warning,
                text: "${jsonData['thongbao']}");
          } else {
            setStateIfMounted(() {
              _soluong = jsonData['soluong'];
              _tongtien = jsonData['tongtien'];
            });
          }
        } on Exception {
          QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              text: "Vui lòng kiểm tra kết nối mạng");
        }
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

  Future<void> getMoneyTinhTrang(String idban) async {
    try {
      final response =
          await http.get(Uri.parse(url + 'tableorder/addBill.php?id=${idban}'));
      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> jsonData = json.decode(response.body);
          setStateIfMounted(() {
            _soluong = jsonData['soluong'];
            _tongtien = jsonData['tongtien'].toString();
          });
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
  Widget build(BuildContext context) {
    final Map<String, dynamic> data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setStateIfMounted(() {
      idban = data['idban'];
      getMoneyTinhTrang(idban.toString());
    });
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          bottomNavigationBar: Container(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              height: 80,
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Color(0xFF4B2C20),
                        borderRadius: BorderRadius.circular(5)),
                    child: Icon(
                      FontAwesomeIcons.trash,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/confirmAndBillOrder',
                            arguments: {
                              'idban': data['idban'],
                              'ten': data['ten'],
                              'username': data['username']
                            });
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Color(0xFF4B2C20),
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                _soluong == null ? '0' : '${_soluong}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                '|',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              'Tổng tiền',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            Expanded(
                              child: Text(
                                _tongtien == null
                                    ? '0 đ'
                                    : '${convertToCurrencyFormat(_tongtien.toString())} đ',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              )),
          appBar: AppBar(
            title: Text('${data['ten']}'),
            centerTitle: true,
            shadowColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 5,
          ),
          backgroundColor: Color.fromARGB(255, 252, 246, 238),
          body: Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "Menu",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 16,
                    color: Color(0xff000000),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _loaiList.asMap().entries.map((entry) {
                            int index = entry.key;
                            return ChoiceChip(
                              selectedColor: Colors.yellow,
                              label: Text(entry.value.tenloai),
                              selected: value == index,
                              onSelected: (selected) {
                                setStateIfMounted(() {
                                  if (selected == false) {
                                    fetchProducts(0);
                                    value = selected ? index : 0;
                                  } else {
                                    fetchProducts(int.parse(entry.value.id));
                                    value = selected ? index : 0;
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GridView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: false,
                    scrollDirection: Axis.vertical,
                    physics: ScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.65,
                    ),
                    children: [
                      for (final product in _products)
                        Material(
                          shadowColor: Colors.grey,
                          elevation: 5,
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image(
                                      height: 180,
                                      width: 200,
                                      image: NetworkImage(url + product.image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Text(
                                  product.ten,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Color(0xff000000),
                                  ),
                                ),
                                new Spacer(),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 10, 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        "${convertToCurrencyFormat(product.gia)} đ",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.yellow,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              padding: EdgeInsets.all(2),
                                              child: InkWell(
                                                onTap: () {
                                                  uploadOrder(data['idban'],
                                                      product.id);
                                                },
                                                child: Icon(
                                                  Icons.add,
                                                  color: Color(0xff212435),
                                                  size: 24,
                                                ),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
