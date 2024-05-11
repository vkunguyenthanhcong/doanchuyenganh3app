import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class MyCurvedNavigationBar extends StatelessWidget {
  final Function(int)? onTap;

  MyCurvedNavigationBar({this.onTap});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: Colors.white,
      buttonBackgroundColor: Colors.white,
      backgroundColor: Colors.blueAccent,
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 500),
      letIndexChange: (index) => true,
      index: 0,
      items: <Widget>[
        Icon(Icons.home, size: 30),
        Icon(Icons.list, size: 30),
        Icon(Icons.compare_arrows, size: 30),
        Icon(Icons.call_split, size: 30),
        Icon(Icons.perm_identity, size: 30),
      ],
      onTap: onTap,
    );
  }
}