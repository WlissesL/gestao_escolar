import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _isLoading = false; // Para o indicador de carregamento

  Future<void> _login() async {
    String cpf = _cpfController.text;
    String senha = _senhaController.text;

    // Validação dos campos
    if (cpf.isEmpty || senha.isEmpty) {
      _showError('CPF e Senha são obrigatórios');
      return;
    }  

    setState(() {
      _isLoading = true; // Ativa o indicador de carregamento
    });

    var url = Uri.parse('http://10.0.2.2:5000/login');

    // Imprimindo valores de depuração
    print('Tentando fazer login com CPF: $cpf e Senha: $senha');

    try {
      var response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'content-Type': 'application/json'
        },
        body: jsonEncode({'cpf': cpf, 'senha': senha}),
        encoding: Encoding.getByName('utf-8')
      );

      setState(() {
        _isLoading = false; // Desativa o indicador de carregamento
      });

      // Imprimindo o status da resposta e o corpo da resposta
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

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
              // Adicionando um ícone de login
              Icon(
                Icons.person_outline,
                size: 100,  // Definindo o tamanho do ícone
                color: Colors.white,  // Cor do ícone
              ),
              const SizedBox(height: 20), // Espaçamento entre o ícone e o título
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
                controller: _cpfController,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: const InputDecoration(
                  labelText: "CPF",
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
