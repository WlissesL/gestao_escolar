import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _isLoading = false; // Para o indicador de carregamento

  Future<void> _login() async {
    String usuario = _usuarioController.text;
    String senha = _senhaController.text;

    // Validação dos campos
    if (usuario.isEmpty || senha.isEmpty) {
      _showError('Usuário e Senha são obrigatórios');
      return;
    }

    setState(() {
      _isLoading = true; // Ativa o indicador de carregamento
    });

    var url = Uri.parse('http://10.0.2.2:5000/login'); // URL da API

    try {
      var response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'usuario': usuario, 'senha': senha}),
      );

      setState(() {
        _isLoading = false; // Desativa o indicador de carregamento
      });

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['mensagem'] == 'Login bem-sucedido!') {
          Navigator.pushReplacementNamed(context, '/home'); // Navegação para Home
        } else {
          _showError(jsonResponse['mensagem']);
        }
      } else {
        _showError('Erro ao conectar ao servidor. Código: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Desativa o indicador de carregamento em caso de erro
      });
      _showError('Erro de rede: ${e.toString()}');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.person_outline,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                "Faça seu Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              TextFormField(
                controller: _usuarioController,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: const InputDecoration(
                  labelText: "Usuário",
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              const Divider(),
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: const InputDecoration(
                  labelText: "Senha",
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: _isLoading ? null : _login, // Desabilita o botão se está carregando
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      )
                    : const Text(
                        "Entrar",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Navegar de volta
                },
                child: const Text(
                  "Voltar",
                  style: TextStyle(color: Colors.blueAccent),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
