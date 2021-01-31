import 'package:cartas/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  var res = await GetStorage.init();
  print('GetStorage initialized: $res');
  runApp(
    GetMaterialApp(
      home: Login(),
      theme: ThemeData(
        primaryColor: Color(0xFF1b998b),
        accentColor: Color(0xFF1b998b),
        hintColor: Color(0xFFc8c8c8),
        textTheme: Typography.whiteMountainView,
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (state) => state.contains(MaterialState.pressed)
                  ? Color(0xFF12685e)
                  : Color(0xFF1b998b),
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (_) => Colors.white,
            ),
          ),
        ),
        focusColor: Color(0xFF1b998b),
        scaffoldBackgroundColor: Color(0xFF1a3a3a),
      ),
    ),
  );
}
