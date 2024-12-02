from flask import Flask, request, jsonify
from flask_cors import CORS
import pymysql
from werkzeug.security import check_password_hash

app = Flask(__name__)
CORS(app)

def get_db_connection():
    return pymysql.connect(
        host='localhost',
        user='root',
        passwd='',  # Adicione sua senha do MySQL
        db='app_gestao_escolar'
    )

# Rota para login
@app.route('/login', methods=['POST'])
def login():
    dados = request.get_json()
    usuario = dados.get('usuario')
    senha = dados.get('senha')

    if not usuario or not senha:
        return jsonify({'mensagem': 'Usuário e senha são obrigatórios'}), 400

    connection = get_db_connection()
    cursor = connection.cursor()

    sql = "SELECT senha FROM login WHERE usuario = %s"

    try:
        cursor.execute(sql, (usuario,))
        resultado = cursor.fetchone()

        if resultado:
            senha_armazenada = resultado[0]
            if check_password_hash(senha_armazenada, senha):
                return jsonify({'mensagem': 'Login bem-sucedido!'}), 200
            else:
                return jsonify({'mensagem': 'Usuário ou senha incorretos.'}), 401
        else:
            return jsonify({'mensagem': 'Usuário não encontrado.'}), 404
    except pymysql.MySQLError as e:
        return jsonify({'mensagem': 'Erro ao realizar login', 'erro': str(e)}), 500
    finally:
        cursor.close()
        connection.close()

# Listar professores
@app.route('/professores', methods=['GET'])
def listar_professores():
    connection = get_db_connection()
    cursor = connection.cursor()

    sql = "SELECT id_professor, nome, especialidade, email, fk_gestao, fk_login FROM professor"

    try:
        cursor.execute(sql)
        resultado = cursor.fetchall()

        professores = [
            {
                'id_professor': row[0],
                'nome': row[1],
                'especialidade': row[2] or 'Não especificada',
                'email': row[3],
                'fk_gestao': row[4] if row[4] is not None else 'N/A',
                'fk_login': row[5] if row[5] is not None else 'N/A'
            }
            for row in resultado
        ]

        return jsonify(professores), 200
    except pymysql.MySQLError as e:
        return jsonify({'mensagem': 'Erro ao buscar professores', 'erro': str(e)}), 500
    finally:
        cursor.close()
        connection.close()

# Cadastrar professores
@app.route('/cadastrarProfessor', methods=['POST'])
def cadastrarProfessor():
    dados = request.get_json()
    nome = dados.get('nome')
    especialidade = dados.get('especialidade')
    email = dados.get('email')
    fk_gestao = dados.get('fk_gestao')
    fk_login = dados.get('fk_login')

    if not nome or not email:
        return jsonify({'mensagem': 'Nome e email são obrigatórios'}), 400

    connection = get_db_connection()
    cursor = connection.cursor()

    sql = "INSERT INTO professor (nome, especialidade, email, fk_gestao, fk_login) VALUES (%s, %s, %s, %s, %s)"

    try:
        cursor.execute(sql, (nome, especialidade, email, fk_gestao, fk_login))
        connection.commit()
        return jsonify({'mensagem': 'Professor cadastrado com sucesso!'}), 201
    except pymysql.MySQLError as e:
        return jsonify({'mensagem': 'Erro ao cadastrar professor', 'erro': str(e)}), 400
    
    except Exception as e:

        return jsonify({'mensagem': 'Erro inesperado', 'erro': str(e)}), 500  # Captura de erros inesperados
    finally:
        cursor.close()
        connection.close()

@app.route('/atualizarProfessor/<int:id_professor>', methods=['PUT'])
def atualizarProfessor(id_professor):
    dados = request.get_json()  # Recebe os dados do corpo da requisição
    nome = dados.get('nome')
    especialidade = dados.get('especialidade')
    email = dados.get('email')

    # Verificar se os campos obrigatórios foram enviados
    if not nome or not email:
        return jsonify({'mensagem': 'Nome e e-mail são obrigatórios'}), 400

    connection = get_db_connection()
    cursor = connection.cursor()

    # SQL para atualizar o professor com base no ID
    sql = "UPDATE professor SET nome = %s, especialidade = %s, email = %s WHERE id_professor = %s"

    try:
        # Executa a atualização no banco de dados
        cursor.execute(sql, (nome, especialidade, email, id_professor))
        connection.commit()

        # Verificar se algum registro foi atualizado
        if cursor.rowcount == 0:
            return jsonify({'mensagem': 'Professor não encontrado'}), 404

        return jsonify({'mensagem': 'Professor atualizado com sucesso!'}), 200

    except pymysql.MySQLError as e:
        return jsonify({'mensagem': 'Erro ao atualizar professor', 'erro': str(e)}), 500

    except Exception as e:
        return jsonify({'mensagem': 'Erro inesperado', 'erro': str(e)}), 500

    finally:
        cursor.close()
        connection.close()


@app.route('/deletarProfessor/<int:id>', methods=['DELETE'])
def delete_teacher(id):
    try:
        print(f"Tentando excluir professor com ID: {id}")  # Log para depuração
        # Conexão com o banco
        connection = get_db_connection()
        cursor = connection.cursor()

        # Comando de exclusão
        cursor.execute('DELETE FROM professor WHERE id_professor = %s', (id,))
        connection.commit()

        if cursor.rowcount == 0:
            return jsonify({'mensagem': 'Professor não encontrado.'}), 404

        return jsonify({'mensagem': 'Professor deletado com sucesso!'}), 200
    except Exception as e:
        return jsonify({'mensagem': 'Erro ao deletar professor', 'erro': str(e)}), 400
    finally:
        cursor.close()
        connection.close()


@app.route('/aluno', methods=['GET'])
def listarAlunos():
    connection = get_db_connection()
    cursor = connection.cursor(pymysql.cursors.DictCursor)  # Retorna os resultados como dicionários

    sql = "SELECT * FROM aluno"

    try:
        cursor.execute(sql)
        alunos = cursor.fetchall()  # Recupera todos os registros da tabela aluno
        return jsonify(alunos), 200
    except pymysql.MySQLError as e:
        return jsonify({'mensagem': 'Erro ao listar alunos', 'erro': str(e)}), 400
    except Exception as e:
        return jsonify({'mensagem': 'Erro inesperado', 'erro': str(e)}), 500
    finally:
        cursor.close()
        connection.close()



@app.route('/cadastrarAluno', methods=['POST'])
def cadastrarAluno():
    dados = request.get_json()
    nome = dados.get('nome')
    data_nascimento = dados.get('data_nascimento')
    matricula = dados.get('matricula')
    fk_turma = dados.get('fk_turma')
    fk_gestao = dados.get('fk_gestao')

    # Verificar campos obrigatórios
    if not nome or not matricula:
        return jsonify({'mensagem': 'Nome e matrícula são obrigatórios'}), 400

    connection = get_db_connection()
    cursor = connection.cursor()

    sql = "INSERT INTO aluno (nome, data_nascimento, matricula, fk_turma, fk_gestao) VALUES (%s, %s, %s, %s, %s)"

    try:
        # Executar a consulta
        cursor.execute(sql, (nome, data_nascimento, matricula, fk_turma, fk_gestao))
        connection.commit()
        return jsonify({'mensagem': 'Aluno cadastrado com sucesso!'}), 201
    except pymysql.MySQLError as e:
        return jsonify({'mensagem': 'Erro ao cadastrar aluno', 'erro': str(e)}), 400
    except Exception as e:
        return jsonify({'mensagem': 'Erro inesperado', 'erro': str(e)}), 500
    finally:
        cursor.close()
        connection.close()
@app.route('/atualizarAluno/<int:id_aluno>', methods=['PUT'])
def atualizarAluno(id_aluno):
    dados = request.get_json()  # Recebe os dados do corpo da requisição
    nome = dados.get('nome')
    matricula = dados.get('matricula')  # Adicionando matrícula
    fk_turma = dados.get('fk_turma')
    data_nascimento = dados.get('data_nascimento')  # Adicionando data de nascimento

    # Verificar se os campos obrigatórios foram enviados
    if not nome or not matricula or not data_nascimento:
        return jsonify({'mensagem': 'Nome, matrícula e data de nascimento são obrigatórios'}), 400

    connection = get_db_connection()
    cursor = connection.cursor()

    # SQL para atualizar o aluno com base no ID (sem o campo e-mail)
    sql = """
        UPDATE aluno 
        SET 
            nome = %s, 
            matricula = %s, 
            fk_turma = %s, 
            data_nascimento = %s  -- Incluindo data de nascimento
        WHERE id_aluno = %s
    """

    try:
        # Executa a atualização no banco de dados
        cursor.execute(sql, (nome, matricula, fk_turma, data_nascimento, id_aluno))
        connection.commit()

        # Verificar se algum registro foi atualizado
        if cursor.rowcount == 0:
            return jsonify({'mensagem': 'Aluno não encontrado'}), 404

        return jsonify({'mensagem': 'Aluno atualizado com sucesso!'}), 200

    except pymysql.MySQLError as e:
        return jsonify({'mensagem': 'Erro ao atualizar aluno', 'erro': str(e)}), 500

    except Exception as e:
        return jsonify({'mensagem': 'Erro inesperado', 'erro': str(e)}), 500

    finally:
        cursor.close()
        connection.close()






@app.route('/deletarAluno/<int:id>', methods=['DELETE'])
def delete_aluno(id):
    try:
        print(f"Tentando excluir aluno com ID: {id}")  # Log para depuração
        # Conexão com o banco
        connection = get_db_connection()
        cursor = connection.cursor()

        # Comando de exclusão
        cursor.execute('DELETE FROM aluno WHERE id_aluno = %s', (id,))
        connection.commit()

        if cursor.rowcount == 0:
            return jsonify({'mensagem': 'Aluno não encontrado.'}), 404

        return jsonify({'mensagem': 'Aluno deletado com sucesso!'}), 200
    except Exception as e:
        return jsonify({'mensagem': 'Erro ao deletar aluno', 'erro': str(e)}), 400
    finally:
        cursor.close()
        connection.close()
        


@app.route('/listarTurmas', methods=['GET'])
def listar_turmas():
    try:
        connection = get_db_connection()
        cursor = connection.cursor()

        cursor.execute("SELECT id_turma, nome_turma, serie FROM turma")
        turmas = cursor.fetchall()

        turmas_list = []
        for turma in turmas:
            turmas_list.append({
                'id_turma': turma[0],
                'nome_turma': turma[1],
                'serie': turma[2]
            })

        return jsonify(turmas_list), 200
    except Exception as e:
        return jsonify({'mensagem': 'Erro ao listar turmas', 'erro': str(e)}), 400
    finally:
        cursor.close()
        connection.close()














if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
