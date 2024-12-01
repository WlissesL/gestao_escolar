import 'package:flutter/material.dart';
import 'package:gestao_escolar/screens/editTeacher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ManageTeacher extends StatefulWidget {
  const ManageTeacher({super.key});

  @override
  State<ManageTeacher> createState() => _ManageTeacherState();
}

class _ManageTeacherState extends State<ManageTeacher> {
  List<Map<String, dynamic>> teachers = [];
  bool isLoading = true;

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
                    title: Text(teacher['nome'] ?? 'Sem nome'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(teacher['especialidade'] ?? 'Sem especialidade'),
                        Text(teacher['email'] ?? 'Sem e-mail'),
                        Text('ID: ${teacher['id_professor']}'),  // Exibe o ID
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Editteacher(
                              teacher: teacher,
                              onSave: fetchTeachers,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
