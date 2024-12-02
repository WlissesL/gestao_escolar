import 'package:flutter/material.dart';
import 'package:gestao_escolar/screens/manageStudents.dart';
import 'package:gestao_escolar/screens/manageTeacher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String nomeUsuario = "Usuário"; // Esse valor poderia ser passado ao fazer login

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sistema de Gestão Escolar"),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer( // Menu lateral
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Bem-vindo, $nomeUsuario!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                // Navegar para o dashboard
                Navigator.pop(context); 
              },
            ),
            ListTile(
              leading: Icon(Icons.person_2),
              title: const Text('Gerenciar Professores'),
              onTap: () {
                // Navegar para relatórios
                Navigator.push(
                  context,
                   MaterialPageRoute(builder: (context)=> ManageTeacher()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Gerenciar Alunos'),
              onTap: () {
                // Navegar para gerenciamento de alunos
                Navigator.push(
                  context,
                   MaterialPageRoute(builder: (context)=> ManageStudent()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: const Text('Relatórios'),
              onTap: () {
                // Navegar para relatórios
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Bem-vindo, $nomeUsuario!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: const Text("Sair"),
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    // Lógica de logout
    Navigator.pushReplacementNamed(context, '/login');
  }
}
