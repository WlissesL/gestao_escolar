import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Importar o pacote intl

class EditStudent extends StatefulWidget {
  final Map<String, dynamic> student;
  final Future<void> Function() onSave;

  const EditStudent({
    super.key,
    required this.student,
    required this.onSave,
  });

  @override
  State<EditStudent> createState() => _EditStudentState();
}

class _EditStudentState extends State<EditStudent> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _dataNascimentoController = TextEditingController(); // Controller para data de nascimento
  final _matriculaController = TextEditingController(); // Controller para matrícula
  int? _selectedTurmaId;
  List<Map<String, dynamic>> _turmas = [];

  @override
  void initState() {
    super.initState();
    _fetchTurmas();

    // Tratar valores nulos e converter matrícula para String
    _nomeController.text = widget.student['nome'] ?? '';
    
    // Se a data de nascimento for válida, formate para 'yyyy-MM-dd'
    String dataNascimento = widget.student['data_nascimento'] ?? '';
    if (dataNascimento.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(dataNascimento);
        _dataNascimentoController.text = DateFormat('yyyy-MM-dd').format(parsedDate); // Formata para 'yyyy-MM-dd'
      } catch (e) {
        _dataNascimentoController.text = ''; // Se houver erro na data, deixe vazio
      }
    }
    
    _matriculaController.text = widget.student['matricula']?.toString() ?? ''; // Conversão para string
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
    // Converter a data para o formato yyyy-MM-dd usando o pacote intl
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(DateTime.parse(_dataNascimentoController.text));

    final url = Uri.parse('http://10.0.2.2:5000/atualizarAluno/${widget.student['id_aluno']}');
    final body = json.encode({
      'nome': _nomeController.text,
      'data_nascimento': formattedDate, // Enviar a data formatada
      'matricula': int.parse(_matriculaController.text), // Convertendo de volta para int
      'fk_turma': _selectedTurmaId,
    });

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aluno atualizado com sucesso!')),
        );
        widget.onSave(); // Atualiza a lista de alunos após a edição
        Navigator.pop(context); // Retorna para a tela anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar aluno')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar aluno: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Aluno'),
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
                controller: _dataNascimentoController,
                decoration: InputDecoration(labelText: 'Data de Nascimento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a data de nascimento do aluno';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _matriculaController,
                decoration: InputDecoration(labelText: 'Matrícula'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a matrícula do aluno';
                  }
                  if (int.tryParse(value) == null) {
                    return 'A matrícula deve ser um número válido';
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
                    if (_selectedTurmaId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Por favor, selecione uma turma.')),
                      );
                      return;
                    }
                    updateStudent();
                  }
                },
                child: Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
