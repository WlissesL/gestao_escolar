import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gestao_escolar/screens/LoginPage.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final _formKey = GlobalKey<FormState>();
  String nome = '';
  String dataNascimento = '';
  String cpf = '';
  String senha = '';

  Future<void> _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, String> data = {
        'nome': nome,
        'data_nascimento': dataNascimento,
        'cpf': cpf,
        'senha': senha,
      };

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/cadastro'),
        headers: <String, String>{
          'Accept':'application/json',
          'content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Usuário cadastrado com sucesso!'),
            ],
          )),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar usuário!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent.shade700,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView( // Para evitar overflow em telas pequenas
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 100,
                  ),
                  SizedBox(height: 20),

                  // Título
                  Text(
                    "Faça seu Cadastro",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),

                  // Campo Nome
                  TextFormField(
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    decoration: InputDecoration(
                      labelText: "Nome Completo",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu nome completo';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        nome = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  // Campo Data de Nascimento
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Data de Nascimento (YYYY-MM-DD)",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua data de nascimento';
                      }
                      final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                      if (!regex.hasMatch(value)) {
                        return 'Formato de data inválido. Use YYYY-MM-DD.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        dataNascimento = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  // Campo CPF
                  TextFormField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    decoration: InputDecoration(
                      labelText: "CPF",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu CPF';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        cpf = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  // Campo Senha
                  TextFormField(
                    obscureText: true,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    decoration: InputDecoration(
                      labelText: "Senha",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        senha = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),

                  // Botão Cadastrar
                  ElevatedButton(
                    onPressed: _cadastrar,
                    child: Text(
                      "Cadastrar-se",
                      style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Botão Voltar
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Voltar",
                      style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
