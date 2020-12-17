import 'dart:async';
import 'package:flutter/material.dart';
import '../Models/medicamento.dart';
import '../Utils/database_helper.dart';
import 'medicamento_detail.dart';
import 'package:sqflite/sqflite.dart';

class MedicamentoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MedicamentoListState();
  }
}

class MedicamentoListState extends State<MedicamentoList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Medicamento> medicamentoList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (medicamentoList == null) {
      medicamentoList = List<Medicamento>();
      updateListView();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Medicamentos'),
        ),
        body: getMedicamentoListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToDetail(Medicamento('', '', ''), 'Novo Medicamento');
          },
          tooltip: 'Novo Medicamento',
          child: Icon(Icons.add),
        ));
  }

  Column getMedicamentoListView() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: count,
            itemBuilder: (BuildContext context, int position) {
              return Dismissible(
                key: ValueKey(medicamentoList[position]),
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
                                this.medicamentoList[position].nome +
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
                  _delete(context, medicamentoList[position]);
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.red,
                        child: Text(
                            getFirstLetter(this.medicamentoList[position].nome),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                      title: Text(this.medicamentoList[position].nome,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(this.medicamentoList[position].prescricao,
                          style: TextStyle(fontSize: 18)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          GestureDetector(
                            child: Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            onTap: () {
                              navigateToDetail(this.medicamentoList[position],
                                  'Editar Medicamento');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  getFirstLetter(String nome) {
    return nome.substring(0, 2).toUpperCase();
  }

  void _delete(BuildContext context, Medicamento medicamento) async {
    //Delete relationship with Agenda on table agenda_medicamento
    await databaseHelper.deleteAgendaMedicamentoByMedicamentoId(medicamento.id);

    int result = await databaseHelper.deleteMedicamento(medicamento.id);
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

  void navigateToDetail(Medicamento medicamento, String nome) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MedicamentoDetail(medicamento, nome);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Medicamento>> medicamentoListFuture =
          databaseHelper.getMedicamentoList();
      medicamentoListFuture.then((medicamentoList) {
        setState(() {
          this.medicamentoList = medicamentoList;
          this.count = medicamentoList.length;
        });
      });
    });
  }
}
