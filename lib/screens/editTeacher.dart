import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Editteacher extends StatefulWidget {
  final Map<String, dynamic> teacher; // Dados do professor a serem editados
  final VoidCallback onSave; // Função de callback para atualizar a lista

  const Editteacher({required this.teacher, required this.onSave, super.key});

  @override
  State<Editteacher> createState() => _EditteacherState();
}

class _EditteacherState extends State<Editteacher> {
  late TextEditingController nameController;
  late TextEditingController specialityController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.teacher['nome']);
    specialityController = TextEditingController(text: widget.teacher['especialidade']);
    emailController = TextEditingController(text: widget.teacher['email']);
  }

  Future<void> updateTeacher() async {
    final id = widget.teacher['id_professor']; // Obtém o ID correto do professor
    final url = Uri.parse('http://10.0.2.2:5000/atualizarProfessor/$id'); // URL da API com ID do professor

    // Validação de campos
    if (nameController.text.isEmpty || specialityController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos os campos devem ser preenchidos!')),
      );
      return; // Não envia a requisição se algum campo estiver vazio
    }

    try {
      // Enviar a requisição PUT
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'}, // Definir cabeçalho como JSON
        body: json.encode({
          'nome': nameController.text, // Enviar os dados atualizados do professor
          'especialidade': specialityController.text,
          'email': emailController.text,
        }),
      );

      // Verificar se a requisição foi bem-sucedida
      if (response.statusCode == 200) {
        // Exibir mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Professor atualizado com sucesso!')),
        );
        widget.onSave(); // Chama a função de callback para atualizar a lista
        Navigator.pop(context); // Volta para a página anterior
      } else {
        // Exibir erro se a resposta não for 200 OK
        final responseMessage = json.decode(response.body)['mensagem'] ?? 'Falha ao atualizar professor';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseMessage)),
        );
      }
    } catch (e) {
      // Exibir erro em caso de falha na requisição
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar professor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Professor'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: specialityController,
              decoration: InputDecoration(
                labelText: 'Especialidade',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: updateTeacher, // Chama a função de atualização do professor
                child: Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
