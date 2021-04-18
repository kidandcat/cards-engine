import 'package:flutter/material.dart';

class CustomImput extends StatelessWidget {
  final Function(String val) onChanged;
  final String title;
  final String description;
  final bool obscureText;
  const CustomImput({
    Key key,
    this.onChanged,
    this.title,
    this.description,
    this.obscureText: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: new InputDecoration(
        border: new OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.teal)),
        hintText: description,
        labelText: title,
        suffixStyle: const TextStyle(color: Colors.green),
      ),
    );
  }
}
