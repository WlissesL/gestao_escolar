import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Editstudent extends StatefulWidget {
  final Map<String, dynamic> student;
  final Future<void> Function() onSave;

  const Editstudent({
    super.key,
    required this.student,
    required this.onSave,
  });

  @override
  State<Editstudent> createState() => _EditstudentState();
}

class _EditstudentState extends State<Editstudent> {
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

    _nomeController.text = widget.student['nome'];
    _cursoController.text = widget.student['curso'];
    _emailController.text = widget.student['email'];
    _selectedTurmaId = widget.student['fk_turma'];
  }

  Future<void> _fetchTurmas() async {
    final url = Uri.parse('http://10.0.2.2:5000/listarTurmas');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _turmas = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Erro ao carregar turmas: $e');
    }
  }

  Future<void> updateStudent() async {
    final url = Uri.parse('http://10.0.2.2:5000/atualizarAluno/${widget.student['id_aluno']}');
    final body = json.encode({
      'nome': _nomeController.text,
      'curso': _cursoController.text,
      'email': _emailController.text,
      'fk_turma': _selectedTurmaId,
    });

    try {
      final response = await http.put(url, headers: {'Content-Type': 'application/json'}, body: body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aluno atualizado com sucesso!')));
        widget.onSave();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar aluno')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar aluno: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Aluno'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nomeController, decoration: InputDecoration(labelText: 'Nome'), validator: (value) {
                if (value == null || value.isEmpty) return 'Digite o nome do aluno';
                return null;
              }),
              TextFormField(controller: _cursoController, decoration: InputDecoration(labelText: 'Curso'), validator: (value) {
                if (value == null || value.isEmpty) return 'Digite o curso do aluno';
                return null;
              }),
              TextFormField(controller: _emailController, decoration: InputDecoration(labelText: 'E-mail'), validator: (value) {
                if (value == null || value.isEmpty) return 'Digite o e-mail do aluno';
                return null;
              }),
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedTurmaId,
                onChanged: (int? newValue) => setState(() {
                  _selectedTurmaId = newValue;
                }),
                items: _turmas.map((turma) {
                  return DropdownMenuItem<int>(
                    value: turma['id_turma'],
                    child: Text('${turma['nome_turma']} (${turma['serie']})'),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Selecione a Turma'),
                validator: (value) {
                  if (value == null) return 'Selecione a turma';
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: () {
                if (_formKey.currentState!.validate()) {
                  updateStudent();
                }
              }, child: Text('Salvar Alterações')),
            ],
          ),
        ),
      ),
    );
  }
}
