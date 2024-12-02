import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Addstudent extends StatefulWidget {
  final VoidCallback onSave; // Callback para atualizar a lista

  const Addstudent({super.key, required this.onSave});

  @override
  State<Addstudent> createState() => _AddstudentState();
}

class _AddstudentState extends State<Addstudent> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cursoController = TextEditingController();
  final _emailController = TextEditingController();
  int? _selectedTurmaId;
  List<Map<String, dynamic>> _turmas = [];

  @override
  void initState() {
    super.initState();
    _fetchTurmas();
  }

  // Função para buscar turmas
  Future<void> _fetchTurmas() async {
    final url = Uri.parse('http://10.0.2.2:5000/listarTurmas');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _turmas = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Falha ao carregar turmas');
      }
    } catch (e) {
      print('Erro ao carregar turmas: $e');
    }
  }

  // Função para adicionar aluno
  Future<void> addStudent() async {
    final url = Uri.parse('http://10.0.2.2:5000/adicionarAluno');
    final body = json.encode({
      'nome': _nomeController.text,
      'curso': _cursoController.text,
      'email': _emailController.text,
      'fk_turma': _selectedTurmaId,  // Enviar o ID da turma selecionada
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aluno adicionado com sucesso!')),
        );
        widget.onSave();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar aluno: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar aluno: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Aluno'),
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
                    return 'Digite o nome do aluno';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cursoController,
                decoration: InputDecoration(labelText: 'Curso'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o curso do aluno';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-mail'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o e-mail do aluno';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedTurmaId,
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedTurmaId = newValue;
                  });
                },
                items: _turmas.map((turma) {
                  return DropdownMenuItem<int>(
                    value: turma['id_turma'],
                    child: Text('${turma['nome_turma']} (${turma['serie']})'),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Selecione a Turma'),
                validator: (value) {
                  if (value == null) {
                    return 'Selecione a turma';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addStudent();
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
