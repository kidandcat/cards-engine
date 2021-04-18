import 'package:cartas/networking.dart';
import 'package:flutter/material.dart';

import 'components/Input.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Networking nk = Networking();
  String email = '';
  String password = '';
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
                    CustomImput(
                      key: Key('email'),
                      onChanged: (value) => email = value,
                      title: 'Email',
                      description: 'Enter your email',
                    ),
                    CustomImput(
                      key: Key('password'),
                      obscureText: true,
                      onChanged: (value) => password = value,
                      title: 'Password',
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
                        key: Key('login_button'),
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
