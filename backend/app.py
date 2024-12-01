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
    fk_gestao = dados.get('fk_gestao')
    fk_login = dados.get('fk_login')

    # Verificar se os campos obrigatórios foram enviados
    if not nome or not email:
        return jsonify({'mensagem': 'Nome e e-mail são obrigatórios'}), 400

    if not fk_gestao or not fk_login:
        return jsonify({'mensagem': 'Gestão e login são obrigatórios'}), 400

    connection = get_db_connection()
    cursor = connection.cursor()

    # SQL para atualizar o professor com base no ID
    sql = "UPDATE professor SET nome = %s, especialidade = %s, email = %s, fk_gestao = %s, fk_login = %s WHERE id_professor = %s"

    try:
        # Executa a atualização no banco de dados
        cursor.execute(sql, (nome, especialidade, email, fk_gestao, fk_login, id_professor))
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




if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
