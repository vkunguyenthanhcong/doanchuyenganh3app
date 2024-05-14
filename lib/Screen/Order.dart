import 'dart:async';
import 'dart:convert';

import 'package:coffee_manager/MyCustomPainter.dart';
import 'package:coffee_manager/Screen/BottomNavBar.dart';
import 'package:coffee_manager/global.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
class TableOrder {
  final String id;
  final String ten;
  final String tinhtrang;
  String total_money = '0';

  TableOrder({
    required this.id,
    required this.ten,
    required this.tinhtrang,
    required this.total_money,
  });
}
String convertToCurrencyFormat(String input) {
  final numberFormat = NumberFormat("#,##0.###", "vi_VN");
  final number = int.parse(input);
  return numberFormat.format(number);
}
class Order extends StatefulWidget {
  final String? username;
  const Order({Key? key, this.username}) : super(key: key);

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  final TextEditingController tenController = TextEditingController();
  List<TableOrder> _tableorder = [];
  late SharedPreferences tableorder;
  bool isLoading = true;
  Timer? timer;
  String? _fullname;

  @override
  void initState() {
    
    super.initState();
    setStateIfMounted(() {
      isLoading = true;
    });
    fetchTableOrder();
    setStateIfMounted(() {
      isLoading = false;
    });
    Timer.periodic(Duration(seconds:5), (Timer t) => fetchTableOrder());
  }
   void setStateIfMounted(f) {
    if (mounted) setState(f);
  }
  Future<void> _ThemKhuVuc(String _ten) async {
    if (!mounted) return;
    final Uri apiUrl = Uri.parse(url + "tableorder/getTableOrder.php");
    final response = await http.post(
      apiUrl,
      body: {"ten": _ten},
    );

    if (response.statusCode == 200) {
      String message = "";
      try {
        Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          Navigator.pop(context);
          fetchTableOrder();
        }else{
           QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: "Khu Vực Đã Tồn Tại");
        }
      } on Exception {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: "Khu Vực Đã Tồn Tại");
      }
    } else {
      Navigator.pop(context);
      throw Exception('Failed');
    }
  }

  Future<void> fetchTableOrder() async {
    bool success = false;
    final response = await http.get(
        Uri.parse(url + "tableorder/getTableOrder.php"));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      for (var item in jsonData){
        setStateIfMounted(() {
          success = item['success'] ?? true;
        });
      }
      if (success == false) {
        
      }else{
        List<dynamic> data = jsonDecode(response.body);
      setStateIfMounted(() {
        _tableorder = data
            .map((item) => TableOrder(
                  id: item['id'],
                  ten: item['ten'],
                  tinhtrang: item['tinhtrang'],
                  total_money: item['total_money'] ?? '0',
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
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order"),
        centerTitle: true,
        shadowColor: Colors.grey,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Padding(
                  padding: EdgeInsets.fromLTRB(20, 250, 20, 250),
                  child: GestureDetector(
                    onTap: () =>
                        FocusScope.of(context).requestFocus(new FocusNode()),
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      backgroundColor: Colors.transparent,
                      body: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 50, 0, 50),
                              child: Text("Thêm Khu Vực",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Form(
                                child: Column(
                                  children: [
                                    Material(
                                        elevation: 5,
                                        shadowColor: Colors.grey,
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        child: TextFormField(
                                          controller: tenController,
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
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1),
                                            ),
                                            hintText: "Tên khu vực",
                                            hintStyle: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 14,
                                              color: Color(0xff989898),
                                            ),
                                            filled: true,
                                            fillColor: Color(0xffFFFFFF),
                                          ),
                                        )),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 20, 20, 0),
                                      child: MaterialButton(
                                        onPressed: () {
                                          _ThemKhuVuc(tenController.text);
                                        },
                                        color: Color(0xFF4B2C20),
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          side: BorderSide(
                                              color: Color(0xFF4B2C20),
                                              width: 1),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Text(
                                          "Thêm Khu Vực",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                        textColor: Color(0xffffffff),
                                        height: 50,
                                        minWidth:
                                            MediaQuery.of(context).size.height,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ));
            },
          );
        },

        child: Icon(Icons.add),
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(188, 75, 44, 32), //<-- SEE HERE
      ),
      backgroundColor: Color.fromARGB(134, 248, 235, 216),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView(
              padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
              shrinkWrap: false,
              scrollDirection: Axis.vertical,
              physics: ScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              children: [
                for (final to in _tableorder)
                  InkWell(
                    onTap: () async {
                      Navigator.pushNamed(context, '/addOrder',
                          arguments: {'ten': to.ten, 'idban': to.id, 'username' : username});
                    },
                    child: Material(
                      elevation: 5,
                      shadowColor: Colors.grey,
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          decoration: CustomDecoration(
                              frameSFactor: .05,
                              gap: 12,
                              tinhtrang: to.tinhtrang),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: Text(
                                    to.ten,
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 16,
                                      color: Color(0xff000000),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "${convertToCurrencyFormat(to.total_money)} đ",
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 12,
                                    color: Color(0xff000000),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                  )
              ],
            ),
    );
  }
}
