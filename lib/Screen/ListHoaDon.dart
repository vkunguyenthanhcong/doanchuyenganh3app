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

String convertToCurrencyFormat(String input) {
  final numberFormat = NumberFormat("#,##0.###", "vi_VN");
  final number = int.parse(input);
  return numberFormat.format(number);
}

class ListHoaDon extends StatefulWidget {
  const ListHoaDon({Key? key}) : super(key: key);

  @override
  _ListHoaDonState createState() => _ListHoaDonState();
}

class _ListHoaDonState extends State<ListHoaDon> {
  List<Map<String, dynamic>> _data = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse(url + "tableorder/order.php?hoadon"));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setStateIfMounted(() {
        _data = jsonData.cast<Map<String, dynamic>>();
        print(_data);
      });
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  }

  Map<String, List<Map<String, dynamic>>> groupDataByDate() {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (var item in _data) {
      String date = item['giovao'];
      if (!groupedData.containsKey(date)) {
        groupedData[date] = [];
      }
      groupedData[date]!.add(item);
    }

    return groupedData;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedData = groupDataByDate();
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text('Hóa Đơn'),
              centerTitle: true,
              shadowColor: Colors.grey,
              backgroundColor: Colors.white,
              elevation: 5,
            ),
            backgroundColor: Colors.white,
            body: ListView.builder(
              itemCount: groupedData.length,
              itemBuilder: (context, index) {
                String date = groupedData.keys.elementAt(index);
                List<Map<String, dynamic>> dataList = groupedData[date]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'Ngày: $date',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Column(
                      children: dataList.map((item) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFF1affff),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(FontAwesomeIcons.moneyBill1),
                            title: Text(
                              'ID: ${item['idhoadon']}',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                                'HÓA ĐƠN', style: TextStyle(fontWeight: FontWeight.w600),),
                                          ),
                                          
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            subtitle: Text(
                              'Tổng tiền: ${convertToCurrencyFormat(item['tongtien'])} đ',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            )));
  }
}
