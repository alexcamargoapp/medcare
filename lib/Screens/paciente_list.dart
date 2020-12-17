import 'dart:async';
import 'package:flutter/material.dart';
import '../Models/paciente.dart';
import '../Utils/database_helper.dart';
import '../Screens/paciente_detail.dart';
import 'package:sqflite/sqflite.dart';

class PacienteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PacienteListState();
  }
}

class PacienteListState extends State<PacienteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Paciente> pacienteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (pacienteList == null) {
      pacienteList = List<Paciente>();
      updateListView();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Paciente'),
        ),
        body: getPacienteListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToDetail(Paciente('', '', ''), 'Novo Paciente');
          },
          tooltip: 'Novo Paciente',
          child: Icon(Icons.add),
        ));
  }

  Column getPacienteListView() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: count,
            itemBuilder: (BuildContext context, int position) {
              return Dismissible(
                key: ValueKey(pacienteList[position]),
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
                            content: Text('Quer remover este paciente ?'),
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
                  _delete(context, pacienteList[position]);
                },
                child: Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.red,
                        child: Text(
                            getFirstLetter(this.pacienteList[position].nome),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                      title: Text(this.pacienteList[position].nome,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(this.pacienteList[position].diagnostico,
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
                              navigateToDetail(this.pacienteList[position],
                                  'Editar Paciente');
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

  void _delete(BuildContext context, Paciente paciente) async {
    int result = await databaseHelper.deletePaciente(paciente.id);
    if (result != 0) {
      _showSnackBar(context, 'Paciente Excluido com Sucesso');
      updateListView();
    } else
      _showSnackBar(context, 'Falha ao excluir Paciente');
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Paciente paciente, String nome) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PacienteDetail(paciente, nome);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Paciente>> pacienteListFuture =
          databaseHelper.getPacienteList();
      pacienteListFuture.then((pacienteList) {
        setState(() {
          this.pacienteList = pacienteList;
          this.count = pacienteList.length;
        });
      });
    });
  }
}
