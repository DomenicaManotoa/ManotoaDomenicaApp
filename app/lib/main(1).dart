// ignore_for_file: prefer_const_constructors
import 'package:app/services/auth/login_or_register.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginOrRegister(),
    );
  }
}