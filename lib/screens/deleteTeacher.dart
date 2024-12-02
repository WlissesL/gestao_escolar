import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Deleteteacher extends StatefulWidget {
  final Map<String, dynamic> teacher;  // Recebe as informações do professor
  final VoidCallback onDelete;  // Callback para atualizar a lista após a exclusão

  const Deleteteacher({super.key, required this.teacher, required this.onDelete});

  @override
  State<Deleteteacher> createState() => _DeleteteacherState();
}

class _DeleteteacherState extends State<Deleteteacher> {
  bool isDeleting = false;  // Para controlar o estado de exclusão (loading)

  // Função para deletar o professor
  Future<void> deleteTeacher(BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2:5000/deletarProfessor/${widget.teacher['id_professor']}');

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
          SnackBar(content: Text('Professor deletado com sucesso!')),
        );
        widget.onDelete();  // Atualiza a lista após exclusão
        Navigator.pop(context);  // Volta para a tela anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao deletar professor, código: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isDeleting = false;  // Finaliza o loading
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar professor: $e')),
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
          content: Text('Tem certeza de que deseja excluir este professor?'),
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
                deleteTeacher(context);  // Chama a função de exclusão
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
        title: Text('Excluir Professor'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${widget.teacher['nome']}'),
            Text('Especialidade: ${widget.teacher['especialidade']}'),
            Text('E-mail: ${widget.teacher['email']}'),
            SizedBox(height: 20),
            isDeleting
                ? Center(child: CircularProgressIndicator())  // Indicador de loading durante a exclusão
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                    onPressed: () {
                      showDeleteConfirmation(context);  // Exibe o diálogo de confirmação
                    },
                    child: Text('Excluir Professor', style: TextStyle(color: Colors.white)),
                  ),
          ],
        ),
      ),
    );
  }
}
