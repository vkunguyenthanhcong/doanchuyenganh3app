import 'dart:convert';
import 'dart:io';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coffee_manager/NavigationBar.dart';
import 'package:coffee_manager/Screen/BottomNavBar.dart';
import 'package:coffee_manager/global.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Product {
  final String id;
  final String ten;
  final String image;
  final String gia;
  final String loai;

  Product(
      {required this.id,
      required this.ten,
      required this.image,
      required this.gia,
      required this.loai});
}

String convertToShortNumber(int value) {
  if (value >= 1000000) {
    return (value / 1000000).toStringAsFixed(0) + 'M';
  } else if (value >= 1000) {
    return (value / 1000).toStringAsFixed(0) + 'K';
  } else {
    return value.toString();
  }
}

class TrangChu extends StatefulWidget {
  final String? fullname;
  const TrangChu({Key? key, this.fullname}) : super(key: key);

  @override
  _TrangChuState createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  String? _fullname;
  List<Product> _products = [];
  bool isLoading = true;
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fullname = widget.fullname;
    fetchProducts();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    final response = await http.get(Uri.parse(url + "chart/chart.php"));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        _data = jsonData.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
    setState(() {});
  }

  List<charts.Series<Map<String, dynamic>, String>> _createSeries() {
    _data.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB);
    });
    return [
      charts.Series(
        id: 'Doanh thu (VNĐ)',
        data: _data,
        domainFn: (Map<String, dynamic> sales, _) {
          DateTime date = DateTime.parse(sales['date']);
          return DateFormat('dd-MM').format(date);
        },
        measureFn: (Map<String, dynamic> sales, _) => int.parse(sales['total']),
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        labelAccessorFn: (Map<String, dynamic> sales, _) =>
            convertToShortNumber(int.parse(sales['total'])),
      )
    ];
  }

  Widget _buildChart() {
    final valueFormatter =
        charts.BasicNumericTickFormatterSpec.fromNumberFormat(
            NumberFormat.compact());
    return charts.BarChart(
      _createSeries(),
      animate: true,
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickFormatterSpec: valueFormatter,
      ),
      barGroupingType: charts.BarGroupingType.grouped,
      behaviors: [
        charts.SeriesLegend(),
      ],
    );
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse(url + "product/hotproducts.php"));

    if (response.statusCode == 200) {

        List<dynamic> _data = jsonDecode(response.body);
        for(var item in _data){
          if(item['success'] == false){

          }else{
            setState(() {
          _products = _data
              .map((item) => Product(
                    id: item['id'],
                    ten: item['ten'],
                    image: item['image'],
                    gia: item['gia'],
                    loai: item['loai'],
                  ))
              .toList();
        });
          }
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
        backgroundColor: Color.fromARGB(134, 248, 235, 216),
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      "Xin chào, ",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.normal,
                        fontSize: 18,
                        color: Color(0xff000000),
                      ),
                    ),
                    Text(
                      '$fullname',
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        fontSize: 18,
                        color: Color(0xff000000),
                      ),
                    ),
                  ],
                ),
                Text(
                  "Mỗi ngày tốt lành! ☕",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text(
                    "Phổ Biến",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.normal,
                      fontSize: 18,
                      color: Color(0xff000000),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: _products.map((product) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Container(
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                          width: 150,
                          height: 215,
                          decoration: BoxDecoration(
                            color: Color(0xffffffff),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Stack(
                                alignment: Alignment.topLeft,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      imageUrl: url + product.image,
                                      placeholder: (context, url) =>
                                          new Padding(
                                              padding: EdgeInsets.all(15)),
                                      errorWidget: (context, url, error) =>
                                          new Icon(Icons.error),
                                      height: 150,
                                      width: 200,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 5, 5, 0),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white),
                                            child: Padding(
                                              padding: EdgeInsets.all(7),
                                              child: Icon(
                                                FontAwesomeIcons
                                                    .fireFlameCurved,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                            )),
                                      )),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                                child: Text(
                                  product.ten,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Color(0xff000000),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Doanh thu 7 ngày gần đây',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: SizedBox(
                    height: 300,
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : InteractiveViewer(child: _buildChart()),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
