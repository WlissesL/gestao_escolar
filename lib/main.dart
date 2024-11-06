import 'package:flutter/material.dart';
import 'package:gestao_escolar/screens/LoginPage.dart';
import 'package:gestao_escolar/screens/home.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Gestão Escolar',
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => Home(), // Rota para a tela Home
      },
    ),
  );
}   