import 'package:coffee_manager/Screen/AddOrder.dart';
import 'package:coffee_manager/Screen/BottomNavBar.dart';
import 'package:coffee_manager/Screen/ConfirmAndBillOrder.dart';
import 'package:coffee_manager/Screen/DangKy.dart';
import 'package:coffee_manager/Screen/DangKyLichLam.dart';
import 'package:coffee_manager/Screen/DangNhap.dart';
import 'package:coffee_manager/Screen/HomeScreen.dart';
import 'package:coffee_manager/Screen/LichLamViec.dart';
import 'package:coffee_manager/Screen/ListHoaDon.dart';
import 'package:coffee_manager/Screen/Order.dart';
import 'package:coffee_manager/Screen/Profile.dart';
import 'package:coffee_manager/Screen/QuanLyNhanVien.dart';
import 'package:coffee_manager/Screen/ThemLoaiSP.dart';
import 'package:coffee_manager/Screen/ThemSanPham.dart';
import 'package:coffee_manager/Screen/ThongTinNhanVien.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MyApp());
  FlutterNativeSplash.remove(); 
  
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Coffee App Manage",
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      routes: <String, WidgetBuilder>{
        '/': (context) => DangNhapWidget(),
        '/dangky' : (context) => DangKyWidget(),
        '/trangchu' : (context) => BottomNavBar(),
        '/themsanpham' : (context) => ThemSanPham(),
        '/order' : (context) => Order(),      
        '/addOrder' : (context) => AddOrder(),
        '/confirmAndBillOrder' : (context) => ConfirmAndBillOrder(), 
        '/listHoaDon' : (context) => ListHoaDon(),    
        '/themloaisp' : (context) => ThemLoaiSP(),
        '/lichlamviec' : (context) => LichLamViec(),
        '/dangkylichlam' : (context) => DangKyLichLam(),
        '/quanlynhanvien' : (context) => QuanLyNhanVien(),
        '/thongtinnhanvien' : (context) => ThongTinNhanVien(),
        },
    );
  }
  
}