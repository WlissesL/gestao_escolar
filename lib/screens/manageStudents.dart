import 'package:flutter/material.dart';
import 'package:gestao_escolar/screens/addstudents.dart';
import 'package:gestao_escolar/screens/deletestudent.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Importando o pacote intl
import 'editstudent.dart'; // Certifique-se de que a classe está nomeada corretamente

class ManageStudent extends StatefulWidget {
  const ManageStudent({super.key});

  @override
  State<ManageStudent> createState() => _ManageStudentState();
}

class _ManageStudentState extends State<ManageStudent> {
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  // Função para buscar os alunos
  Future<void> fetchStudents() async {
    final url = Uri.parse('http://10.0.2.2:5000/aluno');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          students = data.map((e) => e as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar alunos');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar alunos: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Alunos"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = {
                  'id_aluno': students[index]['id_aluno'],
                  'nome': students[index]['nome'] ?? 'Sem nome',
                  'matricula': students[index]['matricula'] ?? 'Sem matrícula',
                  'data_nascimento': students[index]['data_nascimento'] ?? 'Sem data de nascimento',
                  'fk_turma': students[index]['fk_turma'] ?? null,
                };

                // Formatar a data de nascimento antes de exibi-la
                String formattedDate = student['data_nascimento'];
                if (formattedDate != 'Sem data de nascimento') {
                  try {
                    // Tentando converter a string para DateTime
                    DateTime date = DateTime.parse(formattedDate);
                    formattedDate = DateFormat('dd/MM/yyyy').format(date); // Formato padrão dd/MM/yyyy
                  } catch (e) {
                    // Caso não consiga fazer o parse, marca como 'Data inválida'
                    formattedDate = 'Data inválida';
                  }
                }

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(student['nome'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Matrícula: ${student['matricula']}'), // Exibição da matrícula
                          Text('Data de Nascimento: $formattedDate'), // Exibindo a data formatada
                          Text('ID: ${student['id_aluno']}'),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botão de editar
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditStudent(
                                  student: student,
                                  onSave: fetchStudents, // Atualizar lista após edição
                                ),
                              ),
                            );
                          },
                        ),
                        // Botão de excluir
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeleteStudent(
                                  student: student,
                                  onDelete: fetchStudents, // Atualizar lista após exclusão
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Addstudent(
                onSave: fetchStudents, // Atualizar lista após adicionar
              ),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}
