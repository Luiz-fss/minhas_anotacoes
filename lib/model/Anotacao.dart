

class Anotacao{
  /*os atributos são os mesmos da tabela que foi criada na classe
  * "AnotacaoHelper" para inserir no Banco*/

  int id;
  String titulo;
  String descricao;
  String data;

  //Construtor, não é necessário passar o id pois irá ser gerado automaticamente

  Anotacao(this.titulo,this.descricao,this.data);

  Anotacao.fromMap(Map map){

    this.id = map["id"];
    this.titulo=map["titulo"];
    this.descricao = map["descricao"];
    this.data=map["data"];

  }

  Map toMap(){
    Map<String, dynamic> map = {
      "titulo": this.titulo,
      "descricao": this.descricao,
      "data": this.data

    };

    /*para inserir um dado não vamos precisar usar o id, mas quando for
    * atualizar vamos precisar, por isso foi feita a validação abaixo*/

    if(this.id != null){
      map["id"]= this.id;
    }

    return map;
  }

}