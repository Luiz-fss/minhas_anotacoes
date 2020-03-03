import 'package:minhas_anotacoes/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


/*classe no padrão Singleton, pois sempre vai retornar uma única instância
* pq para manipular o Banco de dados não vai precisar de várias instâncias*/

class AnotacaoHelper{

  /*Variavél de nome criada afim de evitar erros de digitação quando
  * utilizamos o nome da tabela*/
  static final String nomeTabela = "anotacao";
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();

  Database _db;

  factory AnotacaoHelper(){
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal(){
  }
  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await _inicializarDb();
      return _db;
    }
  }

    _onCreate(Database db, int version)async{

      String sql = "CREATE TABLE $nomeTabela (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR, descricao TEXT, data DATETIME)";
     await db.execute(sql);

    }

    _inicializarDb() async{
      final caminhoBancoDados = await getDatabasesPath();
      final localBancoDados = join(caminhoBancoDados,"banco_minhas_anotacoes.db");

      var db = await openDatabase(
        localBancoDados,
        version: 1,
        onCreate: _onCreate,
      );
      return db;
    }

    /*O método salvarAnotacao irá receber um objeto do tipo Anotacao
    * para isso foi criado uma classe modelo para anotacao e conseguimos
    * utilizar aqui*/
    Future<int>salvarAnotacao(Anotacao anotacao)async{

      var bancoDados = await db;
      //Para passar a anotação para o insert é preciso transformar em um map
      /*
      Como o uso dessa estrutura de map é recorrente, foi melhor deixar direto
      na classe "anotacao"
      Map<String, dynamic> map = {
        "titulo": anotacao.titulo,
        "descricao": anotacao.descricao,
        "data": anotacao.data

      };

       */
      int id = await bancoDados.insert(nomeTabela, anotacao.toMap());
      return id;

    }

    Future<int>atualizarAnotacao(Anotacao anotacao) async{
      var bancoDados = await _db;

     return await bancoDados.update(
        nomeTabela,
        anotacao.toMap(),
        where: "id=?",
        whereArgs: [anotacao.id]
      );

    }
  Future<int>removerAnotacao(int id)async{

      var bancoDados = await db;
      return await bancoDados.delete(
          nomeTabela,
        where: "id=?",
        whereArgs: [id]
      );


  }

  recuperarAnotacoes()async{

    var bancoDados = await db;
    /*Variável que vai fazer a consulta no banco*/
    String sql = "SELECT  * FROM $nomeTabela ORDER BY data DESC";

    /*Lista que vai receber o retorno da consulta que foi feita
    * vai criar a lista pegando oq encontrar na consulta que foi passada
    * na String sql*/

    List anocaoes = await bancoDados.rawQuery(sql);
    return anocaoes;

  }

  }

