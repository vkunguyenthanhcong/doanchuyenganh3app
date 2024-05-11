import 'package:flutter/material.dart';

class MyCustomPainter extends CustomPainter {
  final double padding;
  final double frameSFactor;

  MyCustomPainter({
    required this.padding,
    required this.frameSFactor,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final frameHWidth = size.width * frameSFactor;

    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = 4;

    /// background
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(0, 0, size.width, size.height),
          Radius.circular(18),
        ),
        paint);

    /// top left
    canvas.drawLine(
      Offset(0 + padding, padding),
      Offset(
        padding + frameHWidth,
        padding,
      ),
      paint..color = Colors.black,
    );

    canvas.drawLine(
      Offset(0 + padding, padding),
      Offset(
        padding,
        padding + frameHWidth,
      ),
      paint..color = Colors.black,
    );

    /// top Right
    canvas.drawLine(
      Offset(size.width - padding, padding),
      Offset(size.width - padding - frameHWidth, padding),
      paint..color = Colors.black,
    );
    canvas.drawLine(
      Offset(size.width - padding, padding),
      Offset(size.width - padding, padding + frameHWidth),
      paint..color = Colors.black,
    );

    /// Bottom Right
    canvas.drawLine(
      Offset(size.width - padding, size.height - padding),
      Offset(size.width - padding - frameHWidth, size.height - padding),
      paint..color = Colors.black,
    );
    canvas.drawLine(
      Offset(size.width - padding, size.height - padding),
      Offset(size.width - padding, size.height - padding - frameHWidth),
      paint..color = Colors.black,
    );

    /// Bottom Left
    canvas.drawLine(
      Offset(0 + padding, size.height - padding),
      Offset(0 + padding + frameHWidth, size.height - padding),
      paint..color = Colors.black,
    );
    canvas.drawLine(
      Offset(0 + padding, size.height - padding),
      Offset(0 + padding, size.height - padding - frameHWidth),
      paint..color = Colors.black,
    );
  }
@override 
bool shouldRepaint(covariant CustomPainter oldDelegate) => true; //based on your use-cases
 }

 class CustomDecoration extends Decoration {
  final String tinhtrang;
  final Color? backgroundColor;
  final double frameSFactor;
  //defalut padding _Need to check
  final double gap;

  CustomDecoration({
    this.backgroundColor = Colors.transparent,
    required this.frameSFactor,
    required this.gap,
    required this.tinhtrang,
  });
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return CustomDecorationPainter(
        tinhtrang : tinhtrang,
        backgroundColor: backgroundColor!,
        frameSFactor: frameSFactor,
        padding: gap);
  }
}

class CustomDecorationPainter extends BoxPainter {
  final Color backgroundColor;
  final double frameSFactor;
  final double padding;
  final String tinhtrang;

  CustomDecorationPainter({
    required this.backgroundColor,
    required this.frameSFactor,
    required this.padding,
    required this.tinhtrang,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    print(configuration.size!.height);

    final Rect bounds = offset & configuration.size!;
    final frameHWidth = configuration.size!.width * frameSFactor;

    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    /// background
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          bounds,
          
          Radius.circular(5),
        ),
        tinhtrang == '0' ? (paint..color = Colors.white) : (paint..color = Color(0xFFffb3b3)) );

    paint.color = Colors.black;

    /// top left
    canvas.drawLine(
      bounds.topLeft + Offset(padding, padding),
      Offset(bounds.topLeft.dx + frameHWidth, bounds.topLeft.dy) +
          Offset(padding, padding),
      paint,
    );
    canvas.drawLine(
      bounds.topLeft + Offset(padding, padding),
      Offset(bounds.topLeft.dx, bounds.topLeft.dy + frameHWidth) +
          Offset(padding, padding),
      paint,
    );

    //top Right
    canvas.drawLine(
      Offset(bounds.topRight.dx - padding, bounds.topRight.dy + padding),
      Offset(bounds.topRight.dx - padding - frameHWidth,
          bounds.topRight.dy + padding),
      paint,
    );
    canvas.drawLine(
      Offset(bounds.topRight.dx - padding, bounds.topRight.dy + padding),
      Offset(bounds.topRight.dx - padding,
          bounds.topRight.dy + padding + frameHWidth),
      paint..color,
    );

    //bottom Right
    canvas.drawLine(
      Offset(bounds.bottomRight.dx - padding, bounds.bottomRight.dy - padding),
      Offset(bounds.bottomRight.dx - padding,
          bounds.bottomRight.dy - padding - frameHWidth),
      paint,
    );
    canvas.drawLine(
      Offset(bounds.bottomRight.dx - padding, bounds.bottomRight.dy - padding),
      Offset(bounds.bottomRight.dx - padding - frameHWidth,
          bounds.bottomRight.dy - padding),
      paint,
    );
//bottom Left
    canvas.drawLine(
      Offset(bounds.bottomLeft.dx + padding, bounds.bottomLeft.dy - padding),
      Offset(bounds.bottomLeft.dx + padding,
          bounds.bottomLeft.dy - padding - frameHWidth),
      paint,
    );
    canvas.drawLine(
      Offset(bounds.bottomLeft.dx + padding, bounds.bottomLeft.dy - padding),
      Offset(bounds.bottomLeft.dx + padding + frameHWidth,
          bounds.bottomLeft.dy - padding),
      paint,
    );
  }
}