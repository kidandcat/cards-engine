import 'package:cartas/dashboard.dart';
import 'package:cartas/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(GetMaterialApp(
    home: Login(),
    theme: ThemeData(
      primaryColor: Colors.purple,
      buttonColor: Colors.red,
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (_) => Colors.deepPurple),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (_) => Colors.yellow,
          ),
        ),
      ),
    ),
  ));
}
