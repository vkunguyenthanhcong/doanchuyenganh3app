import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coffee_manager/Screen/BottomNavBar.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:printing/printing.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

List<Map<String, dynamic>> _data = [];
List<Map<String, dynamic>> _datas = [];
List<TextEditingController> _controllers = [];

String? _fullname;
String _tenban = "";
String _giovao = "";
String _giora = "";
String _username = "";
String cacheGioVao = "";
late SharedPreferences logindata;

String convertToCurrencyFormat(String input) {
  final numberFormat = NumberFormat("#,##0.###", "vi_VN");
  final number = int.parse(input);
  return numberFormat.format(number);
}

String convertDateTime(String datetime) {
  print(datetime);
  if (datetime != null || datetime != "null") {
    DateTime dateTime = DateTime.parse(datetime);
    String formattedDateTime = DateFormat('HH:mm:ss dd-MM-yyyy').format(dateTime);
    return formattedDateTime;
  } else {
    return '';
  }
}

String getGioRa() {
  DateTime dateTime = DateTime.now();
  String formattedDateTime = DateFormat('HH:mm dd-MM-yyyy').format(dateTime);
  return formattedDateTime;
}

String idHoaDon(String datetime, String idban) {
  String dateTimeString = datetime;
  String formattedDateTime = dateTimeString.replaceAll(RegExp(r'[- :]+'), '');
  return formattedDateTime + 'ban' + idban;
}

class ConfirmAndBillOrder extends StatefulWidget {
  const ConfirmAndBillOrder({Key? key}) : super(key: key);

  @override
  _ConfirmAndBillOrderState createState() => _ConfirmAndBillOrderState();
}

class _ConfirmAndBillOrderState extends State<ConfirmAndBillOrder> {
  bool _Loading = true;
  String _idban = "";
  String _tongtien = "";
  String _tongTiened = "";
  File? _image;
  String imagepath = "";

  @override
  void initState() {
    super.initState();
    initial();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  _downloadAndSaveImage(
      String url,
      BuildContext context,
      String tongtienthanhtoan,
      String idban,
      String gioRa,
      List<Map<String, dynamic>> datas) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      img.Image? image = img.decodeImage(bytes);
      Directory appDocDir = await getApplicationDocumentsDirectory();
      File tempFile = File('${appDocDir.path}/temp_image.png');
      await tempFile.writeAsBytes(img.encodePng(image!));
      setStateIfMounted(() {
        _image = tempFile;
      });
      printDaXacNhanToPdf(
          context, tongtienthanhtoan, idban, gioRa, _image!.path, datas);
    } else {
      throw Exception('Failed to download image');
    }
  }

  Future<void> printDaXacNhanToPdf(
      BuildContext context,
      String tongtienthanhtoan,
      String idban,
      String giora,
      String _imagepath,
      List<Map<String, dynamic>> _daThanhToan) async {
    final font = await PdfGoogleFonts.sourceSansProRegular();
    final fontbold = await PdfGoogleFonts.sourceSansProSemiBold();
    final fontbolditalic = await PdfGoogleFonts.sourceSans3SemiBoldItalic();
    final image = File(_imagepath);
    final imageBytes = await image.readAsBytes();
    try {
      final doc = pw.Document();
      Image imgs = Image.asset(imagepath);
      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'SPACE COFFEE & TEA',
                style: pw.TextStyle(font: fontbold, fontSize: 9),
              ),
              pw.SizedBox(height: 5),
              pw.Align(
                alignment: pw.Alignment.bottomCenter,
                child: pw.Text(
                  'ĐC : Trần Hưng Đạo, Quảng Nam, Việt Nam',
                  style: pw.TextStyle(font: fontbold, fontSize: 9),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'ĐT : 0935704083',
                style: pw.TextStyle(font: fontbold, fontSize: 9),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '--------------------------------',
                style: pw.TextStyle(font: font, fontSize: 9),
              ),
              pw.SizedBox(height: 5),
              _giora == ""
                  ? pw.Text(
                      'PHIẾU TẠM TÍNH',
                      style: pw.TextStyle(font: fontbold, fontSize: 9),
                    )
                  : pw.Text(
                      'HÓA ĐƠN THANH TOÁN',
                      style: pw.TextStyle(font: fontbold, fontSize: 9),
                    ),
              pw.Text(
                'Số HĐ : ${idHoaDon(convertDateTime(cacheGioVao.toString()), idban)}',
                style: pw.TextStyle(font: fontbold, fontSize: 9),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                        (cacheGioVao == null ||
                                cacheGioVao == "null" ||
                                cacheGioVao == "")
                            ? ('Giờ vào : ')
                            : ('Giờ vào : ${convertDateTime(cacheGioVao.toString())}'),
                        style: pw.TextStyle(font: fontbold, fontSize: 8)),
                  ),
                  pw.Text('Bàn : $_tenban',
                      style: pw.TextStyle(font: fontbold, fontSize: 8)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.Expanded(
                      child: pw.Text(
                          'Giờ ra : ${(giora == "" ? 'Chưa thanh toán' : giora)}',
                          style: pw.TextStyle(font: fontbold, fontSize: 8))),
                  pw.Text('NV : $_fullname',
                      style: pw.TextStyle(font: fontbold, fontSize: 8)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder(
                    horizontalInside:
                        pw.BorderSide(width: 0.5, style: pw.BorderStyle.solid)),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(bottom: 5),
                        child: pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text('Tên hàng',
                                style:
                                    pw.TextStyle(font: fontbold, fontSize: 8))),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(bottom: 5),
                        child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('Đ.giá',
                                style:
                                    pw.TextStyle(font: fontbold, fontSize: 8))),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(bottom: 5),
                        child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('SL',
                                style:
                                    pw.TextStyle(font: fontbold, fontSize: 8))),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(bottom: 5),
                        child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('TT',
                                style:
                                    pw.TextStyle(font: fontbold, fontSize: 8))),
                      ),
                    ],
                  ),
                  // Table rows

                  for (var item in _daThanhToan)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(vertical: 5),
                          child: pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(item['ten'].toString(),
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 8,
                                )),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(vertical: 5),
                          child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                  convertToCurrencyFormat(
                                      item['gia'].toString()),
                                  style:
                                      pw.TextStyle(font: font, fontSize: 8))),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(vertical: 5),
                          child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(item['soluong'].toString(),
                                  style:
                                      pw.TextStyle(font: font, fontSize: 8))),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(vertical: 5),
                          child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                  convertToCurrencyFormat(
                                      (int.parse(item['soluong']) *
                                              int.parse(item['gia']))
                                          .toString()),
                                  style:
                                      pw.TextStyle(font: font, fontSize: 8))),
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Thành tiền:',
                      style: pw.TextStyle(font: fontbold, fontSize: 8),
                    ),
                  ),
                  pw.Text(
                    convertToCurrencyFormat(tongtienthanhtoan) + " đ",
                    style: pw.TextStyle(font: fontbold, fontSize: 8),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.center,
                child:
                    pw.Image(pw.MemoryImage(imageBytes), width: 50, height: 50),
              ),
              pw.SizedBox(height: 5),
              pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text('Space cảm ơn và hẹn gặp lại quý khách!',
                      style: pw.TextStyle(font: fontbolditalic, fontSize: 8))),
              pw.SizedBox(height: 20),
              pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text('Powered by 3TL',
                      style: pw.TextStyle(font: font, fontSize: 8))),
            ],
          );
        },
      ));

      // Save PDF to file
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/${idHoaDon(_giovao, idban)}.pdf');
      await file.writeAsBytes(await doc.save());
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => doc.save());
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setStateIfMounted(() {
      _fullname = logindata.getString('fullname')!;
    });
    (_idban == null || _idban == "" || _idban == "null")
        ? setState(() {
            _Loading = true;
          })
        : (
            fetchTongTien(_idban),
            fetchDataDaXacNhan(_idban),
            getGioVao(_idban),
            fetchData(_idban),
          );
  }

  thanhToan(String idban, String idhoadon, String tongtien, String nhanvien) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(url + "tableorder/order.php"));

    request.fields['thanhToan'] = idban;
    request.fields['idhoadon'] = idhoadon;
    request.fields['tongtien'] = tongtien;
    request.fields['giovao'] = _giovao;
    request.fields['nhanvien'] = nhanvien;

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      Map<String, dynamic> data = jsonDecode(responseData);
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "Thanh Toán Thành Công");
      initial();
    } else {
      print('Thanh toán lỗi');
    }
  }

  fetchData(String idban) async {
    final response = await http.get(
        Uri.parse(url + "tableorder/order.php?getListChuaXacNhan=${idban}"));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      setStateIfMounted(() {
        _data = jsonResponse.cast<Map<String, dynamic>>();
        _controllers.clear();
        _controllers.addAll(
            List.generate(_data.length, (_) => TextEditingController()));
        _Loading = false;
      });
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  }

  fetchDataDaXacNhan(String idban) async {
    final response = await http
        .get(Uri.parse(url + "tableorder/order.php?getListDaXacNhan=${idban}"));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      setStateIfMounted(() {
        _datas = jsonResponse.cast<Map<String, dynamic>>();
      });
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  }

  huyDon(String idban) async {
    final response = await http.get(
        Uri.parse(url + "tableorder/order.php?huyDonChuaXacNhan=${idban}"));
    if (response.statusCode == 200) {
      var responseData = await response.body;
      Map<String, dynamic> data = jsonDecode(responseData);
      // Call fetchData again to refresh the data
      fetchData(_idban);
      fetchTongTien(_idban);
    } else {
      print('Failed');
    }
  }

  xacNhan(String idban) async {
    final response = await http
        .get(Uri.parse(url + "tableorder/order.php?xacNhanOrder=${idban}"));
    if (response.statusCode == 200) {
      var responseData = await response.body;
      Map<String, dynamic> data = jsonDecode(responseData);
      // Call fetchData again to refresh the data
      fetchData(_idban);
      fetchTongTien(_idban);
      fetchDataDaXacNhan(_idban);
      getGioVao(_idban);
    } else {
      print('Failed');
    }
  }

  Future<void> getGioVao(String idban) async {
    final response = await http.get(
        Uri.parse(url + "tableorder/order.php?getGioVaoDaXacNhan=${idban}"));
    if (response.statusCode == 200) {
      var responseData = await response.body;
      Map<String, dynamic> data = jsonDecode(responseData);

      if (data['message'] == "false" || data['message'] == false) {
        setStateIfMounted(() {
          _giovao = "";
          _tongTiened = "0";
        });
      } else {
        setStateIfMounted(() {
          _giovao = data['time'];
          cacheGioVao = data['time'];
          _tongTiened = data['tongtien'];
        });
      }
    } else {
      print('Failed');
    }
  }

  Future<void> fetchTongTien(String idban) async {
    final response = await http.get(Uri.parse(
        url + "tableorder/order.php?getTongTienChuaXacNhan=${idban}"));
    if (response.statusCode == 200) {
      var responseData = await response.body;

      Map<String, dynamic> data = jsonDecode(responseData);

      setStateIfMounted(() {
        data['tongtien'] == null
            ? (_tongtien = '0')
            : (_tongtien = data['tongtien']);
      });
    } else {
      print('Failed');
    }
  }

  @override
  void dispose() {
    fetchData(_idban);
    fetchTongTien(_idban);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> dt =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setStateIfMounted(() {
      _idban = dt['idban'];
      _tenban = dt['ten'];
      _username = dt['username'];
    });

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(FontAwesomeIcons.circleDot),
                  text: 'Chưa xác nhận',
                ),
                Tab(
                  icon: Icon(FontAwesomeIcons.circleCheck),
                  text: 'Đã xác nhận',
                ),
              ],
            ),
          ),
          body: _Loading
              ? TabBarView(
                  children: [
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                )
              : TabBarView(
                  children: [
                    ChuaXacNhan(
                      fetchData: fetchData,
                      idban: _idban,
                      controllers: _controllers,
                      data: _data,
                      tongtien: _tongtien,
                      huyDon: huyDon,
                      fetchTongTien: fetchTongTien,
                      xacNhan: xacNhan,
                      fetchDataDaXacNhan: fetchDataDaXacNhan,
                      getGioVao: getGioVao,
                    ),
                    DaXacNhan(
                      fetchDataDaXacNhan: fetchDataDaXacNhan,
                      idban: _idban,
                      tongtienthanhtoan: _tongTiened,
                      thanhToan: thanhToan,
                      downloadAndSaveImage: _downloadAndSaveImage,
                      imagepath: imagepath,
                      image: _image,
                      cacheGioVao: cacheGioVao,
                      datas: _datas,
                      username: _username,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class ChuaXacNhan extends StatelessWidget {
  final Function fetchData; // Pass the fetchData function
  final String idban;
  final List<TextEditingController> controllers;
  final List<Map<String, dynamic>> data;
  final String tongtien;
  final Function huyDon;
  final Function fetchTongTien;
  final Function xacNhan;
  final Function fetchDataDaXacNhan;
  final Function getGioVao;
  const ChuaXacNhan({
    Key? key,
    required this.fetchData,
    required this.idban,
    required this.controllers,
    required this.data,
    required this.tongtien,
    required this.huyDon,
    required this.fetchTongTien,
    required this.xacNhan,
    required this.fetchDataDaXacNhan,
    required this.getGioVao,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
          color: Color(0xFF0099ff),
          height: 120,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Tổng tiền",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              tongtien == "" ? "0 đ" : tongtien + " đ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MaterialButton(
                            onPressed: () async {
                              if (await confirm(context,
                                  title: Text('Xác nhận'),
                                  content: Text('Xác nhận order'),
                                  textOK: Text('Xác nhận'),
                                  textCancel: Text('Hủy'))) {
                                xacNhan(idban);
                              }
                            },
                            color: Color(0xFF0059b3),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side: BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              "Xác nhận",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                            textColor: Color(0xffffffff),
                            height: 50,
                            minWidth: 150,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: MaterialButton(
                              onPressed: () async {
                                if (await confirm(context,
                                    title: Text('Hủy'),
                                    content: Text('Xác nhận hủy đơn hàng'),
                                    textOK: Text('Xác nhận'),
                                    textCancel: Text('Hủy'))) {
                                  huyDon(idban);
                                }
                              },
                              color: Color(0xFFff5c33),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(
                                    color: Colors.transparent, width: 0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                "Hủy",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              textColor: Color(0xffffffff),
                              height: 50,
                              minWidth: 150,
                            ),
                          )
                        ]),
                  ],
                )),
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            dividerTheme: const DividerThemeData(
                              color: Colors.transparent,
                              space: 0,
                              thickness: 0,
                              indent: 0,
                              endIndent: 0,
                            ),
                          ),
                          child: DataTable(
                            horizontalMargin: 0,
                            columnSpacing: 10.0,
                            dividerThickness: 0.0,
                            columns: [
                              DataColumn(label: Text('')),
                              DataColumn(
                                label: Text(''),
                              ),
                              DataColumn(
                                label: Text(''),
                              ),
                            ],
                            rows: _data.map((item) {
                              int index = _data.indexOf(item);
                              _controllers[index].text = item['soluong'];
                              return DataRow(
                                cells: [
                                  DataCell(Container(
                                    width: 50,
                                    child: TextField(
                                      controller: _controllers[index],
                                      obscureText: false,
                                      textAlign: TextAlign.center,
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
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 0.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 0.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 0.5),
                                        ),
                                        filled: true,
                                        fillColor: Color(0xffFFFFFF),
                                        isDense: false,
                                      ),
                                    ),
                                  )),
                                  DataCell(Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.55,
                                      child: Text(
                                        item['ten'].toString(),
                                      ),
                                    ),
                                  )),
                                  DataCell(Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      width: 70,
                                      child: Text(convertToCurrencyFormat(
                                              item['gia'].toString()) +
                                          ' đ'),
                                    ),
                                  )),
                                ],
                              );
                            }).toList(),
                          )),
                    ],
                  ),
                ))));
  }
}

class DaXacNhan extends StatelessWidget {
  final Function fetchDataDaXacNhan;
  final String idban;
  final String tongtienthanhtoan;
  final Function thanhToan;
  final Function downloadAndSaveImage;
  final String imagepath;
  final File? image;
  final String cacheGioVao;
  final List<Map<String, dynamic>> datas;
  final String username;

  const DaXacNhan({
    Key? key,
    required this.fetchDataDaXacNhan,
    required this.idban,
    required this.tongtienthanhtoan,
    required this.thanhToan,
    required this.downloadAndSaveImage,
    required this.imagepath,
    required this.image,
    required this.cacheGioVao,
    required this.datas,
    required this.username,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'HÓA ĐƠN',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text((_giovao == null ||
                              _giovao == "null" ||
                              _giovao == "")
                          ? ('Giờ vào : ')
                          : ('Giờ vào : ${convertDateTime(_giovao.toString())}')),
                    ),
                    Text('Bàn : ${_tenban}'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text('Giờ ra : '),
                    ),
                    Text('NV : ${_fullname}'),
                  ],
                ),
              ),
              Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    dividerTheme: const DividerThemeData(
                      color: Colors.black,
                      space: 0,
                      thickness: 0,
                      indent: 0,
                      endIndent: 0,
                    ),
                  ),
                  child: DataTable(
                    horizontalMargin: 0,
                    columnSpacing: 10.0,
                    dividerThickness: 0.0,
                    columns: [
                      DataColumn(label: Text('Tên hàng')),
                      DataColumn(
                        label: Text('Đ.giá'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text('SL'),
                        ),
                        numeric: false,
                      ),
                      DataColumn(
                        label: Text('TT'),
                        numeric: true,
                      ),
                    ],
                    rows: _datas.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Text(
                              item['ten'].toString(),
                            ),
                          )),
                          DataCell(
                            Container(
                              width: 65,
                              child: Text(
                                convertToCurrencyFormat(
                                  item['gia'].toString(),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          DataCell(Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 25,
                                child: Text(item['soluong'],
                                    textAlign: TextAlign.center),
                              ),
                            ),
                          )),
                          DataCell(Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 65,
                              child: Text(
                                  (convertToCurrencyFormat(
                                      (int.parse(item['soluong']) *
                                              int.parse(item['gia']))
                                          .toString())),
                                  textAlign: TextAlign.right),
                            ),
                          )),
                        ],
                      );
                    }).toList(),
                  )),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                      'Thành tiền:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )),
                    Text(
                      convertToCurrencyFormat(tongtienthanhtoan) + " đ",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              _giovao == ""
                  ? Container()
                  : Image.network(
                      'https://img.vietqr.io/image/tpbank-0935704083-qr_only.jpg?amount=${tongtienthanhtoan}&addInfo=${idHoaDon(convertDateTime(_giovao.toString()), idban)}&accountName=NGUYEN%20THANH%20CONG',
                      width: 100,
                      height: 100,
                    ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      onPressed: () async {
                        if(_giovao != ""){
                          if (await confirm(context,
                            title: Text('Thanh toán'),
                            content: Text('Xác nhận thanh toán'),
                            textOK: Text('Thanh toán'),
                            textCancel: Text('Hủy'))) {
                          downloadAndSaveImage(
                            'https://img.vietqr.io/image/tpbank-0935704083-qr_only.jpg?amount=${tongtienthanhtoan}&addInfo=${idHoaDon(convertDateTime(cacheGioVao.toString()), idban)}&accountName=NGUYEN%20THANH%20CONG',
                            context,
                            tongtienthanhtoan,
                            idban,
                            getGioRa(),
                            datas,
                          );
                          thanhToan(
                              idban,
                              idHoaDon(
                                  convertDateTime(_giovao.toString()), idban),
                              tongtienthanhtoan, username);
                        }
                        }
                      },
                      color: Color(0xFF0059b3),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Color(0xFF0059b3), width: 1),
                      ),
                      child: Text(
                        "Thanh toán",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      textColor: Color(0xffffffff),
                      height: 40,
                      minWidth: 150,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(width: 20),
                    ),
                    MaterialButton(
                      onPressed: () {
                        if(_giovao == ""){
                          
                        }else{
                          downloadAndSaveImage(
                            'https://img.vietqr.io/image/tpbank-0935704083-qr_only.jpg?amount=${tongtienthanhtoan}&addInfo=${idHoaDon(convertDateTime(_giovao.toString()), idban)}&accountName=NGUYEN%20THANH%20CONG',
                            context,
                            tongtienthanhtoan,
                            idban,
                            "",
                            datas);
                        }
                      },
                      color: Color(0xFF0059b3),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Color(0xFF0059b3), width: 1),
                      ),
                      child: Text(
                        "Phiếu tạm tính",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      textColor: Color(0xffffffff),
                      height: 40,
                      minWidth: 150,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
