import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:MedCare/Models/agenda.dart';
import 'package:MedCare/Models/view_agenda_medicamento.dart';
import 'package:MedCare/Utils/database_helper.dart';
import '../main.dart';
import 'add_medicamento_list.dart';
import 'agenda_list.dart';

class AgendaMedicamentoList extends StatefulWidget {
  final Agenda agenda;

  AgendaMedicamentoList(this.agenda);

  @override
  State<StatefulWidget> createState() {
    return AgendaMedicamentoListState(this.agenda);
  }
}

class AgendaMedicamentoListState extends State<AgendaMedicamentoList> {
  Agenda agenda;
  AgendaMedicamentoListState(this.agenda);

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<ViewAgendaMedicamento> vagendamedicamentoList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (vagendamedicamentoList == null) {
      vagendamedicamentoList = List<ViewAgendaMedicamento>();
      updateListView();
    }
    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              navigateToAgendaList();
            },
            child: Icon(
              Icons.arrow_back, // add custom icons also
            ),
          ),
          //elevat
          title: Text('Prescrição/Medicamentos'),
        ),
        body: listMedicamentos(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToAddMedicamentoList(agenda);
          },
          tooltip: 'Adiciona Medicamento',
          child: Icon(Icons.add),
        ));
  }

  Column listMedicamentos() {
    return Column(
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Container(
                    width: 60,
                    height: 40,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: new BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        agenda.horario,
                        style: TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  title: Text(agenda.titulo,
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  subtitle: Text('Conforme relação abaixo'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: count,
              itemBuilder: (BuildContext context, int position) {
                return Dismissible(
                  key: ValueKey(vagendamedicamentoList[position]),
                  background: Container(
                    color: Theme.of(context).errorColor,
                    child: Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 40,
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    margin: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) {
                    return showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              title: Text('Tem certeza?'),
                              content: Text('Quer remover o medicamento ' +
                                  vagendamedicamentoList[position].nome +
                                  ' ?'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Não'),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(false);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Sim'),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(true);
                                  },
                                ),
                              ],
                            ));
                  },
                  onDismissed: (_) {
                    _deleteRelationShipAgendaMedicamento(
                        context,
                        vagendamedicamentoList[position].agendaid,
                        vagendamedicamentoList[position].medicamentoid);
                  },
                  child: Card(
                    color: Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.red,
                        child: Text(
                            getFirstLetter(
                                this.vagendamedicamentoList[position].nome),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold)),
                      ),
                      title: Text(this.vagendamedicamentoList[position].nome,
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          this.vagendamedicamentoList[position].prescricao),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  void navigateToAddMedicamentoList(Agenda agenda) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddMedicamentoList(agenda);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void navigateToAgendaList() async {
    await MyApp.navigatorKey.currentState
        .push(MaterialPageRoute(builder: (context) => AgendaList()));
  }

  void _deleteRelationShipAgendaMedicamento(
      BuildContext context, int agendaid, int medicamentoid) async {
    int result =
        await databaseHelper.deleteAgendaMedicamento(agendaid, medicamentoid);
    if (result != 0) {
      _showSnackBar(context, 'Medicamento Excluido com Sucesso');
      updateListView();
    } else
      _showSnackBar(context, 'Falha ao excluir Medicamento');
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<ViewAgendaMedicamento>> vagendamedicamentoListFuture =
          databaseHelper.getViewAgendaMedicamentoList(agenda.id);
      vagendamedicamentoListFuture.then((vagendamedicamentoList) {
        setState(() {
          this.vagendamedicamentoList = vagendamedicamentoList;
          this.count = vagendamedicamentoList.length;
        });
      });
    });
  }

  getFirstLetter(String nome) {
    return nome.substring(0, 2).toUpperCase();
  }
}
