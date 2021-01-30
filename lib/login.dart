import 'package:cartas/lobby.dart';
import 'package:cartas/networking.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Networking nk = Networking();
  String email;
  String password;
  String error;

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
                    if (error != null)
                      Text(
                        error,
                        style: TextStyle(color: Colors.red),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextButton(
                        child: Text('Log-in'),
                        onPressed: () async {
                          try {
                            await nk.login(email, password);
                            print('Logged in');
                            Get.to(Lobby());
                          } on String catch (e) {
                            print('Error $e');
                            error = e;
                          }
                        },
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
