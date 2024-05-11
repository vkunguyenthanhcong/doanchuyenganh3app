import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

class Loai {
  final String id;
  final String loai;

  Loai({required this.id, required this.loai});

  factory Loai.fromJson(Map<String, dynamic> json) {
    return Loai(
      id: json['id'],
      loai: json['loai'],
    );
  }
}

class ThemSanPham extends StatefulWidget {
  const ThemSanPham({Key? key}) : super(key: key);

  @override
  _ThemSanPhamState createState() => _ThemSanPhamState();
}

class _ThemSanPhamState extends State<ThemSanPham> {
  File? _imageFile;
  File? _defaultImage;
  bool isLoading = false;
  final TextEditingController _ten = TextEditingController();
  final TextEditingController _gia = TextEditingController();
  final TextEditingController _soluong = TextEditingController();
  List<Loai> _loaiList = [];
  Loai _selectedLoai = Loai(id: '-1', loai: 'Loading...');

  @override
  void initState() {
    super.initState();
    fetchLoaiList();
  }

  Future<void> fetchLoaiList() async {
    final response = await http
        .get(Uri.parse(url + "product/themsanpham.php?method=getTypeProduct"));
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        setState(() {
          _loaiList = jsonResponse.map((json) => Loai.fromJson(json)).toList();
          _selectedLoai = _loaiList.first;
        });
      } catch (e) {
        print('Failed to decode JSON: $e');
      }
    } else {
      print('Failed to load loai: ${response.statusCode}');
    }
  }

  Future<void> _getImage(ImageSource source) async {
    setState(() {
      isLoading = true;
    });
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        CompressImage(pickedFile.path);
      });
    }
  }

  Future<Uint8List?> CompressImage(String assetName) async {
    var list = await FlutterImageCompress.compressWithFile(
      assetName,
      minWidth: 500,
      minHeight: 500,
      quality: 50,
    );
    convertUint8ListToFile(list!);
  }

  Future<File?> convertUint8ListToFile(Uint8List data) async {
    try {
      img.Image? image = img.decodeImage(data);
      Directory appDocDir = await getApplicationDocumentsDirectory();
      File tempFile = File('${appDocDir.path}/temp_image.png');
      await tempFile.writeAsBytes(img.encodePng(image!));
      setState(() {
        _imageFile = tempFile;
        isLoading = false;
      });
    } catch (e) {
      print("Error converting Uint8List to file: $e");
      return null;
    }
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Máy ảnh'),
                  onTap: () {
                    _getImage(ImageSource.camera);
                    Navigator.pop(context);
                  }),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Chọn từ thư viện'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadImageAndString() async {
    File? imageFile;
    String ten = _ten.text;
    String gia = _gia.text;
    String soluong = _soluong.text;
    

  if(ten == "" || gia == "" || soluong == "" || _selectedLoai.id == '-1'){
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Bạn vui lòng điền đủ thông tin");
    }else{
       imageFile = _imageFile;
       print(imageFile);
      FocusScope.of(context).requestFocus(new FocusNode());
    var request = http.MultipartRequest(
        'POST', Uri.parse(url + "product/themsanpham.php"));
      var image = await http.MultipartFile.fromPath('image', imageFile!.path);
      request.files.add(image);
      request.fields['ten'] = ten;
    request.fields['gia'] = gia;
    request.fields['soluong'] = soluong;
    request.fields['loai'] = _selectedLoai.id;
    print(_selectedLoai.id);

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();

      var parsedData = json.decode(responseData);
      String imagePath = parsedData['file_path'];
      _ten.text = "";
      _gia.text = "";
      _soluong.text = "";
      _imageFile = null;
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "Thêm Thành Công");
    } else {
      print('Failed to upload image');
    }
    }
    

    
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Thêm Vào Kho Hàng"),
            centerTitle: true,
            shadowColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 5,
          ),
          backgroundColor: Color.fromARGB(255, 252, 246, 238),
          body: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: isLoading == true ? Center(child: CircularProgressIndicator(),) : _imageFile == null
                              ? Image(
                                  image: AssetImage('images/logo.png'),
                                  fit: BoxFit.fill,
                                )
                              : Image.file(_imageFile!),
                        ),
                        Container(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 191, 191, 191),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: InkWell(
                              onTap: () {
                                _showImagePickerOptions();
                              },
                              child: Icon(
                                FontAwesomeIcons.camera,
                                color: Color(0xff000000),
                                size: 24,
                              ),
                            )),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Loại sản phẩm",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<Loai>(
                              value: _selectedLoai,
                              onChanged: (Loai? newValue) {
                                setState(() {
                                  _selectedLoai = newValue!;
                                });
                              },
                              items: _loaiList
                                  .map<DropdownMenuItem<Loai>>((Loai loai) {
                                return DropdownMenuItem<Loai>(
                                  value: loai,
                                  child: Text(loai.loai),
                                );
                              }).toList(),
                            )))),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Tên sản phẩm",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(15.0),
                      child: TextField(
                        controller: _ten,
                        obscureText: false,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(color: Color(0xFFFFFFFF), width: 0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(color: Color(0xFFFFFFFF), width: 0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(color: Color(0xFFFFFFFF), width: 0),
                          ),
                          hintText: "Tên sản phẩm",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Color(0xFFFFFFFF),
                          isDense: false,
                          contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Giá",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(15.0),
                      child: TextField(
                        controller: _gia,
                        obscureText: false,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(color: Color(0xFFFFFFFF), width: 0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(color: Color(0xFFFFFFFF), width: 0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(color: Color(0xFFFFFFFF), width: 0),
                          ),
                          hintText: "0",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Color(0xFFFFFFFF),
                          isDense: false,
                          contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Số lượng",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(15.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _soluong,
                        obscureText: false,
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
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(color: Color(0xFFFFFFFF), width: 0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(color: Color(0xFFFFFFFF), width: 0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                BorderSide(color: Color(0xFFFFFFFF), width: 0),
                          ),
                          hintText: "0",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Color(0xFFFFFFFF),
                          isDense: false,
                          contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: MaterialButton(
                        onPressed: (){
                          
                          if (_imageFile == null){
                            CompressImage('images/logo.png');
                          }else{
                            uploadImageAndString();
                          }},
                            
                        color: Color(0xFF4B2C20),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          side: BorderSide(color: Color(0xFF4B2C20), width: 1),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          "Thêm sản phẩm",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        textColor: Color(0xffffffff),
                        height: 50,
                        minWidth: MediaQuery.of(context).size.height,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
