import 'package:cartas/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

const brandColor = Color(0xFF1a3a3a);
void main() async {
  await GetStorage.init();
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
        scaffoldBackgroundColor: brandColor,
      ),
    ),
  );
}
