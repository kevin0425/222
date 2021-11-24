import 'dart:async';
import 'dart:io';
import 'dart:ffi';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter_opencv_example/myhomepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_opencv_example/native_opencv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_opencv_example/screens/home_page.dart';
import 'package:flutter_opencv_example/theme/colors/light_colors.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: LightColors.kLightYellow, // navigation bar color
    statusBarColor: Color(0xffffb969), // status bar color
  ));

  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: Theme.of(context).textTheme.apply(
            bodyColor: LightColors.kDarkBlue,
            displayColor: LightColors.kDarkBlue,
            fontFamily: 'Poppins'
        ),
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


