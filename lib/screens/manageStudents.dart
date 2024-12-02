import 'package:flutter/material.dart';
import 'package:gestao_escolar/screens/addstudents.dart';
import 'package:gestao_escolar/screens/deletestudent.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'editstudent.dart'; // Certifique-se de importar a tela de edição
import 'deletestudent.dart'; // Importe a tela de exclusão
import 'addstudents.dart';  // Crie e importe a tela de adicionar aluno

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
                final student = students[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(student['nome'] ?? 'Sem nome', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Curso: ${student['curso'] ?? 'Sem curso'}'),
                          Text('E-mail: ${student['email'] ?? 'Sem e-mail'}'),
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
                            // Navegar para a tela de edição
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Editstudent(
                                  student: student,
                                  onSave: fetchStudents, // Atualizar a lista após edição
                                ),
                              ),
                            );
                          },
                        ),
                        // Botão de excluir
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Navegar para a tela de confirmação de exclusão
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Deletestudent(
                                  student: student,
                                  onDelete: fetchStudents, // Atualizar a lista após exclusão
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
      // Botão flutuante para adicionar aluno
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para a tela de adicionar novo aluno
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Addstudent(
                onSave: fetchStudents, // Atualizar a lista após adicionar
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
