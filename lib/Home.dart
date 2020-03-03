//import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minhas_anotacoes/helper/AnotacaoHelper.dart';
import 'package:minhas_anotacoes/model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _tituloControler = TextEditingController();
  TextEditingController _descricaoControler = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();

  _exibirTelaCadastro({Anotacao anotacao}){

    String textoSalvarAtualizar = "";
    if(anotacao==null){
      //salvando anotação
      _tituloControler.text = "";
      _descricaoControler.text ="";
      textoSalvarAtualizar = "Salvar";

    }else{
      //atualizando
      _tituloControler.text = anotacao.titulo;
      _descricaoControler.text = anotacao.descricao;
      textoSalvarAtualizar = "Atualizar";
    }
    
    showDialog(
        context: context,
      builder: (context){
          /*Fix: foi necessário adicionar o SingleChildScrollView para corrigir
          * um erro dado no Layout que estava quebrando no TextField,
          * Padding adicionado para corrigir a posição do Alert, estava
          * ficando por cima do app bar*/
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: AlertDialog(
                title: Text ("$textoSalvarAtualizar anotação"),
                content: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,

                  //define o tamanho do item utilizado
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _tituloControler,
                      //keyboardType: TextInputType.text,
                      autofocus: true,
                      decoration: InputDecoration(
                          labelText: "Título",
                          hintText: "Digite o título..."
                      ),

                    ),

                    TextField(
                      controller: _descricaoControler,
                      //keyboardType: TextInputType.text,
                      //autofocus: true,
                      decoration: InputDecoration(
                          labelText: "Descrição",
                          hintText: "Digite a descrição"
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancelar"
                    ),
                  ),
                  FlatButton(
                    onPressed: () {

                      //salvar
                      _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);

                      Navigator.pop(context);
                    },
                    child: Text(
                        textoSalvarAtualizar
                    ),
                  )
                ],
              ),
            ),
          );
      }
    );
  }

  _recuperarAnotacoes()async{
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> listaTemporaria = List<Anotacao>();
    /*o objeto list que foi criado não é compativel com o tipo do list
    * que foi criado aqui. Por isso foi usado o for para percorrer os valores
    * de anotacoesRecuperadas e em seguida ser adicionadas na lista*/

    for(var item in anotacoesRecuperadas){

      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);

    }
    setState(() {
      _anotacoes = listaTemporaria;
    });
    listaTemporaria =null;
  }

  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async{

    /*recuperando o que foi digitado no Alert Dialog*/
    String titulo = _tituloControler.text;
    String descricao = _descricaoControler.text;

    //validando se estamos salvando uma nova anotação ou atualizando
    if(anotacaoSelecionada == null){

      Anotacao anotacao = Anotacao(titulo,descricao,DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);

    }else{
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();

      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }


    _tituloControler.clear();
    _descricaoControler.clear();

    _recuperarAnotacoes();
  }

  _removerAnotacao(int id) async{

    await _db.removerAnotacao(id);

    _recuperarAnotacoes();
  }

  _formatarData(String data){

    initializeDateFormatting('pt_BR');

    /*Aplicando a formatação
    * Year -> y, month -> M, day -> d*/
    //var formatador = DateFormat("d/MM/y");
    //var formatador = DateFormat.yMd("pt_BR");
    var formatador = DateFormat.yMMMd("pt_BR");
    //Convertendo a data
    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;

  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Anotações"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: _anotacoes.length,
                itemBuilder: (context, index){

                  final anotacao = _anotacoes[index];


                  return Card(
                    child: ListTile(
                      title: Text(
                        anotacao.titulo,

                      ),
                      subtitle: Text(
                          ("${_formatarData(anotacao.data)} - ${anotacao.descricao}"),

                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[

                          GestureDetector(
                            onTap: (){
                              _exibirTelaCadastro(anotacao: anotacao);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                            _removerAnotacao(anotacao.id);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 0),
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                            ),
                          )

                        ],

                      ),
                    ),
                  );
                },
            ),
          )
        ],
      ),
      floatingActionButton:  FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: Icon(
          Icons.add
        ),
        onPressed: (){
        _exibirTelaCadastro();
        },
      ),
    );
  }
}
