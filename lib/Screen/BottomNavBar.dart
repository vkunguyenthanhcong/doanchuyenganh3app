import 'package:coffee_manager/Screen/Dashboard.dart';
import 'package:coffee_manager/Screen/HomeScreen.dart';
import 'package:coffee_manager/Screen/Kho.dart';
import 'package:coffee_manager/Screen/Order.dart';
import 'package:coffee_manager/Screen/Profile.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

String? fullname;
String? username;
bool isLoading = true;
late SharedPreferences logindata;

class _BottomNavBarState extends State<BottomNavBar> {
  int _page = 2;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final pages = [
    Profile(fullname: fullname, username: username,),
    Kho(),
    TrangChu(fullname: fullname),
    Order(username : username),
    Dashboard(),
  ];
  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    
    setState(() {
      fullname = logindata.getString('fullname')!; 
      username = logindata.getString('username')!; 
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          bottomNavigationBar: CurvedNavigationBar(
            key: _bottomNavigationKey,
            index: 2,
            items: <Widget>[
              Icon(Icons.person, size: 30, ),
              Icon(Icons.warehouse_rounded, size: 30),
              FaIcon(FontAwesomeIcons.home, size: 25,),
              Icon(Icons.table_bar, size: 30),
              FaIcon(FontAwesomeIcons.pieChart, size: 30,),
            ],
            color: Colors.white,
            buttonBackgroundColor: Colors.white,
            backgroundColor: Color.fromARGB(188, 75, 44, 32),
            animationCurve: Curves.easeInOut,
            animationDuration: Duration(milliseconds: 600),
            onTap: (index) {
              setState(() {
                _page = index;
              });
            },
            letIndexChange: (index) => true,
          ),
          body: SafeArea(
            top: true,
            child: isLoading ? Center(child: CircularProgressIndicator(),) : pages[_page]
          )),
    );
  }
}
