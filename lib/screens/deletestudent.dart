import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Deletestudent extends StatefulWidget {
  final Map<String, dynamic> student;  // Recebe as informações do aluno
  final VoidCallback onDelete;  // Callback para atualizar a lista após a exclusão

  const Deletestudent({super.key, required this.student, required this.onDelete});

  @override
  State<Deletestudent> createState() => _DeletestudentState();
}

class _DeletestudentState extends State<Deletestudent> {
  bool isDeleting = false;  // Para controlar o estado de exclusão (loading)

  // Função para deletar o aluno
  Future<void> deleteStudent(BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2:5000/deletarAluno/${widget.student['id_aluno']}');

    setState(() {
      isDeleting = true;  // Inicia o loading
    });

    try {
      final response = await http.delete(url);

      setState(() {
        isDeleting = false;  // Finaliza o loading
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aluno deletado com sucesso!')),
        );
        widget.onDelete();  // Atualiza a lista após exclusão
        Navigator.pop(context);  // Volta para a tela anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao deletar aluno, código: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isDeleting = false;  // Finaliza o loading
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar aluno: $e')),
      );
    }
  }

  // Função para confirmar a exclusão
  void showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza de que deseja excluir este aluno?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Fecha o diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Fecha o diálogo
                deleteStudent(context);  // Chama a função de exclusão
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excluir Aluno'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${widget.student['nome']}'),
            Text('Curso: ${widget.student['curso']}'),
            Text('E-mail: ${widget.student['email']}'),
            SizedBox(height: 20),
            isDeleting
                ? Center(child: CircularProgressIndicator())  // Indicador de loading durante a exclusão
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      showDeleteConfirmation(context);  // Exibe o diálogo de confirmação
                    },
                    child: Text('Excluir Aluno', style: TextStyle(color: Colors.white)),
                  ),
          ],
        ),
      ),
    );
  }
}
