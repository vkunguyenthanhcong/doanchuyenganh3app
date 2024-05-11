import 'package:charts_flutter/flutter.dart' as charts;

class CustomNumberFormatter extends charts.BasicNumericTickFormatterSpec {
  CustomNumberFormatter(super.formatter);

  @override
  String formatNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return number.toString();
    }
  }
}