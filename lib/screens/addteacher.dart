import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Addteacher extends StatefulWidget {
  final VoidCallback onSave; // Callback para atualizar a lista

  const Addteacher({super.key, required this.onSave});

  @override
  State<Addteacher> createState() => _AddteacherState();
}

class _AddteacherState extends State<Addteacher> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _especialidadeController = TextEditingController();
  final _emailController = TextEditingController();

  Future<void> addTeacher() async {
    final url = Uri.parse('http://10.0.2.2:5000/cadastrarProfessor');
    final body = json.encode({
      'nome': _nomeController.text,
      'especialidade': _especialidadeController.text,
      'email': _emailController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Professor adicionado com sucesso!')),
        );
        widget.onSave();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar professor: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar professor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Professor'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome do professor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _especialidadeController,
                decoration: InputDecoration(labelText: 'Especialidade'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a especialidade do professor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-mail'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o e-mail do professor';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addTeacher();
                  }
                },
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
