import 'dart:convert';
import 'dart:core';
import 'package:coffee_manager/global.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:http/http.dart' as http;

String getMonthNumber(String monthName) {
  switch (monthName) {
    case 'Tháng 1':
      return '01';
    case 'Tháng 2':
      return '02';
    case 'Tháng 3':
      return '03';
    case 'Tháng 4':
      return '04';
    case 'Tháng 5':
      return '05';
    case 'Tháng 6':
      return '06';
    case 'Tháng 7':
      return '07';
    case 'Tháng 8':
      return '08';
    case 'Tháng 9':
      return '09';
    case 'Tháng 10':
      return '10';
    case 'Tháng 11':
      return '11';
    case 'Tháng 12':
      return '12';
    default:
      return '01'; // Default to January
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
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

class _DashboardState extends State<Dashboard> {
  String? daynow;
  String? _7dayago;
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _datawithmonth = [];
  List<Map<String, dynamic>> _datawithQuarter = [];
  String _dropDownValue = '05';
  bool _isLoading = true;
  Map<String, int> quarterlyData = {
    'Q1': 0,
    'Q2': 0,
    'Q3': 0,
    'Q4': 0,
  };
  List<charts.Series<Map<String, dynamic>, String>> _quarterlySeries = [];
  @override
  void initState() {
    super.initState();
    get7day();
    fetchChartData();
    fetchDataWithQuarter();
  }

  Future<void> fetchDataWithQuarter() async {
    final response = await http.get(Uri.parse(url + "chart/chart.php?home"));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);

      setState(() {
        _datawithQuarter = jsonData.cast<Map<String, dynamic>>();
        calculateQuarterlyRevenue();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void calculateQuarterlyRevenue() {
    _datawithQuarter.sort((a, b) => a['date'].compareTo(b['date']));
    int q1Revenue = 0;
    int q2Revenue = 0;
    int q3Revenue = 0;
    int q4Revenue = 0;
    int currentYear = DateTime.now().year;

    _datawithQuarter.forEach((item) {
      DateTime date = DateTime.parse(item['date']);
      int month = date.month;

      if (date.year == currentYear) {
        if (month >= 1 && month <= 3) {
          q1Revenue += int.parse(item['total']);
        } else if (month >= 4 && month <= 6) {
          q2Revenue += int.parse(item['total']);
        } else if (month >= 7 && month <= 9) {
          q3Revenue += int.parse(item['total']);
        } else if (month >= 10 && month <= 12) {
          q4Revenue += int.parse(item['total']);
        }
      }
    });

    quarterlyData['Q1'] = q1Revenue;
    quarterlyData['Q2'] = q2Revenue;
    quarterlyData['Q3'] = q3Revenue;
    quarterlyData['Q4'] = q4Revenue;

    _quarterlySeries = [
      charts.Series<Map<String, dynamic>, String>(
        id: 'Quý',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (data, _) => data['quarter'],
        measureFn: (data, _) => data['revenue'],
        data: [
          {'quarter': 'Q1', 'revenue': q1Revenue},
          {'quarter': 'Q2', 'revenue': q2Revenue},
          {'quarter': 'Q3', 'revenue': q3Revenue},
          {'quarter': 'Q4', 'revenue': q4Revenue},
        ],
      )
    ];
  }

  get7day() {
    DateTime currentDate = DateTime.now();

    DateTime sevenDaysAgo = currentDate.subtract(Duration(days: 7));
    DateFormat dateFormat = DateFormat('dd/MM');
    String formattedCurrentDate = dateFormat.format(currentDate);
    String formattedSevenDaysAgo = dateFormat.format(sevenDaysAgo);
    setState(() {
      daynow = formattedCurrentDate;
      _7dayago = formattedSevenDaysAgo;
    });
  }

  Future<void> fetchChartData() async {
    final response = await http.get(Uri.parse(url + "chart/chart.php?home"));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      print(jsonData);
      setState(() {
        _data = jsonData.cast<Map<String, dynamic>>();
        _datawithmonth = jsonData.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
    setState(() {});
  }

  List<charts.Series<Map<String, dynamic>, String>> _createSeriesWithMonth(
      String selectedMonth) {
    List<Map<String, dynamic>> filteredData = _datawithmonth.where((item) {
      DateTime date = DateTime.parse(item['date']);
      print(date.month.toString().padLeft(2, '0'));
      return date.month.toString().padLeft(2, '0') == selectedMonth;
    }).toList();

    // Sort filtered data by date
    filteredData.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB);
    });
    return [
      charts.Series(
        id: 'Doanh thu (VNĐ)',
        data: filteredData,
        domainFn: (Map<String, dynamic> sales, _) {
          DateTime date = DateTime.parse(sales['date']);
          return DateFormat('dd').format(date); // Show only the day
        },
        measureFn: (Map<String, dynamic> sales, _) => int.parse(sales['total']),
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        labelAccessorFn: (Map<String, dynamic> sales, _) =>
            convertToShortNumber(int.parse(sales['total'])),
      )
    ];
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

  Widget _buildChartWithMonth() {
    final valueFormatter =
        charts.BasicNumericTickFormatterSpec.fromNumberFormat(
            NumberFormat.compact());
    return charts.BarChart(
      _createSeriesWithMonth(_dropDownValue),
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

  Widget _buildChartWithQuarter() {
    final valueFormatter =
        charts.BasicNumericTickFormatterSpec.fromNumberFormat(
            NumberFormat.compact());
    return charts.BarChart(
      _quarterlySeries,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Quản Lý"),
          centerTitle: true,
          shadowColor: Colors.grey,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 5,
        ),
        backgroundColor: Color.fromARGB(134, 248, 235, 216),
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                  children: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/listHoaDon');
                      },
                      child: Text(
                        'Thống kê',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.primaries.last,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: BorderSide(color: Colors.transparent, width: 1),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    SizedBox(width: 10,),
                    MaterialButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/lichlamviec');
                      },
                      child: Text(
                        'Lịch làm việc',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.primaries.last,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: BorderSide(color: Colors.transparent, width: 1),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    SizedBox(width: 10,),
                    MaterialButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/quanlynhanvien');
                      },
                      child: Text(
                        'Quản lý nhân viên',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.primaries.last,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: BorderSide(color: Colors.transparent, width: 1),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ],
                ),
                ),
                Text(
                  'Doanh thu 7 ngày gần đây (${_7dayago} - ${daynow})',
                  style: TextStyle(fontWeight: FontWeight.w700),
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
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(
                      'Doanh thu theo tháng',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      items: <String>[
                        'Tháng 1',
                        'Tháng 2',
                        'Tháng 3',
                        'Tháng 4',
                        'Tháng 5',
                        'Tháng 6',
                        'Tháng 7',
                        'Tháng 8',
                        'Tháng 9',
                        'Tháng 10',
                        'Tháng 11',
                        'Tháng 12'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: getMonthNumber(value).toString(),
                          child: Text(value),
                        );
                      }).toList(),
                      hint: _dropDownValue == null
                          ? Text('Chọn tháng',
                              style: TextStyle(color: Colors.black))
                          : Text(
                              'Tháng ${_dropDownValue}',
                              style: TextStyle(color: Colors.black),
                            ),
                      onChanged: (val) {
                        setState(() {
                          _dropDownValue = val!;
                          _createSeriesWithMonth(val!);
                        });
                      },
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: SizedBox(
                    height: 300,
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : InteractiveViewer(child: _buildChartWithMonth()),
                  ),
                ),
                Text(
                  'Doanh thu năm 2024',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: SizedBox(
                    height: 300,
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : InteractiveViewer(child: _buildChartWithQuarter()),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
