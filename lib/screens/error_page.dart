import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String message;

  ErrorPage(this.message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(message),
      ),
    );
  }
}
