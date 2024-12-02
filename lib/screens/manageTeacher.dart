import 'package:flutter/material.dart';
import 'package:gestao_escolar/screens/addteacher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Editteacher.dart'; // Certifique-se de importar a tela de edição
import 'Deleteteacher.dart'; // Importe a tela de exclusão
import 'addteacher.dart'; // Crie e importe a tela de adicionar professor

class ManageTeacher extends StatefulWidget {
  const ManageTeacher({super.key});

  @override
  State<ManageTeacher> createState() => _ManageTeacherState();
}

class _ManageTeacherState extends State<ManageTeacher> {
  List<Map<String, dynamic>> teachers = [];
  bool isLoading = true;

  // Função para buscar os professores
  Future<void> fetchTeachers() async {
    final url = Uri.parse('http://10.0.2.2:5000/professores');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          teachers = data.map((e) => e as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar professores');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar professores: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Professores"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final teacher = teachers[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(teacher['nome'] ?? 'Sem nome', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Especialidade: ${teacher['especialidade'] ?? 'Sem especialidade'}'),
                          Text('E-mail: ${teacher['email'] ?? 'Sem e-mail'}'),
                          Text('ID: ${teacher['id_professor']}'),
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
                                builder: (context) => Editteacher(
                                  teacher: teacher,
                                  onSave: fetchTeachers, // Atualizar a lista após edição
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
                                builder: (context) => Deleteteacher(
                                  teacher: teacher,
                                  onDelete: fetchTeachers, // Atualizar a lista após exclusão
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
      // Botão flutuante para adicionar professor
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para a tela de adicionar novo professor
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Addteacher(
                onSave: fetchTeachers, // Atualizar a lista após adicionar
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
