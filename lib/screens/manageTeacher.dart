import 'package:flutter/material.dart';
import 'dart:convert'; // Para trabalhar com JSON
import 'package:http/http.dart' as http;

class ManageTeacher extends StatefulWidget {
  const ManageTeacher({super.key});

  @override
  State<ManageTeacher> createState() => _ManageTeacherState();
}

class _ManageTeacherState extends State<ManageTeacher> {
  List<Map<String, dynamic>> teachers = [];
  bool isLoading = true; // Indicador de carregamento

  // Função para buscar dados da API
  Future<void> fetchTeachers() async {
    final url = Uri.parse('http://<seu-servidor>:5000/professores'); // Atualize com o IP/host correto
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          teachers = data.map((e) => e as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        // Erro na requisição
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
    fetchTeachers(); // Chama a API ao iniciar o widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Professores"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carregamento
          : ListView.builder(
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final teacher = teachers[index];
                return ListTile(
                  title: Text(teacher['nome'] ?? 'Sem nome'),
                  subtitle: Text(teacher['especialidade'] ?? 'Sem especialidade'),
                  leading: Icon(Icons.person),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTeacherScreen(
                                teacherName: teacher['nome'] ?? 'Sem nome',
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Excluir professor (implementar exclusão depois)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Função excluir ainda não implementada')),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTeacherScreen(
                          teacherName: teacher['nome'] ?? 'Sem nome',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTeacherScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class AddTeacherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Professor')),
      body: Center(child: Text('Tela para adicionar um novo professor')),
    );
  }
}

class EditTeacherScreen extends StatelessWidget {
  final String teacherName;

  const EditTeacherScreen({required this.teacherName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar $teacherName')),
      body: Center(child: Text('Tela para editar o professor $teacherName')),
    );
  }
}
