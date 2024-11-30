import 'package:flutter/material.dart';

class Managestudents extends StatefulWidget {
  const Managestudents({super.key});

  @override
  State<Managestudents> createState() => _ManagestudentsState();
}

class _ManagestudentsState extends State<Managestudents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: const Text("Gerenciar Alunos"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text('Aqui você pode gerenciar os alunos!'),
        
      ),
    );
  }
}