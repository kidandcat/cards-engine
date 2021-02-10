import 'package:cartas/networking.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Networking nk = Networking();
  String email = 'jairo@email.com';
  String password = '12341234';
  String error = '';

  void onLoginPress() async {
    try {
      await nk.login(email, password);
      // redirection to lobby is made in networking.dart, on sessionLoaded()
    } on String catch (e) {
      setState(() {
        error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    TextField(
                      autofillHints: ['email'],
                      onChanged: (value) => email = value,
                      decoration: InputDecoration(
                        hintText: 'Email',
                      ),
                    ),
                    TextField(
                      obscureText: true,
                      onChanged: (value) => password = value,
                      decoration: InputDecoration(
                        hintText: 'Password',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        error,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextButton(
                        child: Text('Log in'),
                        onPressed: onLoginPress,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
}
