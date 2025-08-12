import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Flutter Web Works!',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
        ),
      ),
    ),
  );
}