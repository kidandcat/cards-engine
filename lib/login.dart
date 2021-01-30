import 'package:cartas/networking.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Networking nk;

  @override
  void initState() {
    super.initState();
    nk = Networking();
    nk.login();
  }

  @override
  Widget build(BuildContext context) => Container(
        child: Text('Login'),
      );
}
