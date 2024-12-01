from flask import Flask, request, jsonify
from flask_cors import CORS
import pymysql
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
CORS(app)

def get_db_connection():
    connection = pymysql.connect(
        host='localhost',
        user='root',
        passwd='',  # Adicione sua senha do MySQL, se houver
        db='app_gestao_escolar'
    )
    return connection

# Rota para cadastrar um novo usuário
#def cadastrar_usuario():
#   dados = request.get_json()
#    usuario = dados.get('usuario')
#    senha = dados.get('senha')

    # Validação dos campos obrigatórios
 #   if not usuario or not senha:
#      return jsonify({'mensagem': 'Usuário e senha são obrigatórios'}), 400
#
#    Criptografar a senha antes de armazená-la no banco de dados
#  senha_criptografada = generate_password_hash(senha)

#    connection = get_db_connection()
#       cursor = connection.cursor()

# SQL para inserir o novo usuário no banco de dados
#    sql = "INSERT INTO login (usuario, senha) VALUES (%s, %s)"
    
#    try:
#        cursor.execute(sql, (usuario, senha_criptografada))
#        connection.commit()  # Confirmar a transação no banco de dados
#        return jsonify({'mensagem': 'Usuário cadastrado com sucesso!'}), 201
#    except pymysql.MySQLError as e:
#        return jsonify({'mensagem': 'Erro ao cadastrar usuário', 'erro': str(e)}), 500
#    except Exception as e:
#        return jsonify({'mensagem': 'Erro inesperado','erro':str(e)}),500
#    finally:
#        cursor.close()
#        connection.close()

# Rota para login
@app.route('/login', methods=['POST'])
def login():
    dados = request.get_json()
    usuario = dados.get('usuario')
    senha = dados.get('senha')

    # Validação dos dados de entrada
    if not usuario or not senha:
        return jsonify({'mensagem': 'Usuário e senha são obrigatórios'}), 400

    connection = get_db_connection()
    cursor = connection.cursor()

    # SQL para selecionar a senha do usuário
    sql = "SELECT senha FROM login WHERE usuario = %s"

    try:
        cursor.execute(sql, (usuario,))
        resultado = cursor.fetchone()

        if resultado:
            senha_armazenada = resultado[0]
            # Verificar se a senha corresponde
            if check_password_hash(senha_armazenada, senha):
                return jsonify({'mensagem': 'Login bem-sucedido!'}), 200
            else:
                return jsonify({'mensagem': 'Usuário ou senha incorretos.'}), 401
        else:
            return jsonify({'mensagem': 'Usuário não encontrado.'}), 404
    except pymysql.MySQLError as e:
        return jsonify({'mensagem': 'Erro ao realizar login', 'erro': str(e)}), 500
    except Exception as e:
        return jsonify({'mensagem' : 'Erro inesperado', 'erro': str(e)}),500
    finally:
        cursor.close()
        connection.close()

        

@app.route('/professores', methods=['GET'])
def listar_professores():
    connection = get_db_connection()
    cursor = connection.cursor()

    # SQL para selecionar os dados relevantes da tabela `professores`
    sql = """
        SELECT 
            id_professor, 
            nome, 
            especialidade, 
            email, 
            fk_gestao, 
            fk_login 
        FROM professores
    """

    try:
        cursor.execute(sql)
        resultado = cursor.fetchall()

        # Criar uma lista de dicionários para retorno como JSON
        professores = [
            {
                'id_professor': row[0],
                'nome': row[1],
                'especialidade': row[2] if row[2] else 'Não especificada',  # Trata `especialidade` como opcional
                'email': row[3],
                'fk_gestao': row[4] if row[4] is not None else 'N/A',      # Trata FK como opcional
                'fk_login': row[5] if row[5] is not None else 'N/A'         # Trata FK como opcional
            }
            for row in resultado
        ]

        return jsonify(professores), 200
    except pymysql.MySQLError as e:
        return jsonify({'mensagem': 'Erro ao buscar professores', 'erro': str(e)}), 500
    except Exception as e:
        return jsonify({'mensagem': 'Erro inesperado', 'erro': str(e)}), 500
    finally:
        cursor.close()
        connection.close()


@app.route('/cadastrarProfessor',methods = ['POST'])
def cadastrarProfessor():
    dados = request.get_json()
    nome = dados.get('nome')
    especialidade = dados.get('especialidade')
    email = dados.get('email')
    fk_gestao = dados.get('fk_gestao')
    fk_login = dados.get('fk_login')

    if not nome or not email:
        return jsonify ({'mensagem' : 'Nome e email são obrigatório'}), 400
    
    connection = get_db_connection()
    cursor = connection.cursor()


    sql ="INSERT INTO professores ( nome, especialidade, email, fk_gestao, fk_login) VALUES (%s, %s, %s, %s) "


    try:
        cursor.execute(sql,(nome, especialidade, email, fk_gestao, fk_login))
        connection.commit()
        return jsonify({'mensagem' : 'Professor cadastrado com sucesso!'}),201
    except pymysql.MySQLError as e:
        return jsonify ({'mensagem' : 'Erro ao cadastrar professor','erro': str(e)}),400
    finally:
        cursor.close()
        connection.close()




if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
