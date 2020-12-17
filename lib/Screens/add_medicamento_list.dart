import 'dart:async';
import 'package:MedCare/Models/agenda.dart';
import 'package:MedCare/Utils/dialogs.dart';
import 'package:flutter/material.dart';
import '../Models/medicamento.dart';
import '../Models/agenda_medicamento.dart';
import '../Utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class AddMedicamentoList extends StatefulWidget {
  final Agenda agenda;

  AddMedicamentoList(this.agenda);

  @override
  State<StatefulWidget> createState() {
    return AddMedicamentoListState(this.agenda);
  }
}

class AddMedicamentoListState extends State<AddMedicamentoList> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  Agenda agenda;
  AddMedicamentoListState(this.agenda);

  List<Medicamento> medicamentoList;

  AgendaMedicamento agendaMedicamento = AgendaMedicamento(null, null);

  @override
  Widget build(BuildContext context) {
    if (medicamentoList == null) {
      medicamentoList = List<Medicamento>();
      updateListView();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Adiciona Medicamentos'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, true);
              }),
        ),
        body: getMedicamentoListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          tooltip: 'Voltar',
          child: Icon(Icons.keyboard_return),
        ));
  }

  ListView getMedicamentoListView() {
    return ListView.builder(
      itemCount: medicamentoList.length,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            onTap: () {
              agendaMedicamento.medicamentoid =
                  this.medicamentoList[position].id;
              agendaMedicamento.agendaid = agenda.id;
              _setRelationShipAgendaMedicamento(context, position);
            },
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.red,
              child: Text(getFirstLetter(this.medicamentoList[position].nome),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            title: Text(this.medicamentoList[position].nome,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text(this.medicamentoList[position].prescricao,
                style: TextStyle(fontSize: 18)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(
                    Icons.add,
                    color: Colors.blue,
                    size: 40,
                  ),
                  onTap: () {
                    agendaMedicamento.medicamentoid =
                        this.medicamentoList[position].id;
                    agendaMedicamento.agendaid = agenda.id;
                    _setRelationShipAgendaMedicamento(context, position);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  getFirstLetter(String nome) {
    return nome.substring(0, 2).toUpperCase();
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Medicamento>> medicamentoListFuture =
          databaseHelper.getMedicamentoList();
      medicamentoListFuture.then((medicamentoList) {
        setState(() {
          this.medicamentoList = medicamentoList;
        });
      });
    });
  }

  void _setRelationShipAgendaMedicamento(
      BuildContext context, int indexItemList) async {
    int result;
    result = await databaseHelper.insertAgendaMedicamento(agendaMedicamento);
    if (result != 0) {
      // Success
      Dialogs.showAlertDialog(
          'Status',
          this.medicamentoList[indexItemList].nome + ' adicionado com sucesso',
          context);
      removeMedicamentoItemList(indexItemList);
    } else {
      // Failure
      Dialogs.showAlertDialog(
          'Atenção', 'Falha ao adicionar medicamento', context);
    }
  }

  void removeMedicamentoItemList(int index) {
    setState(() {
      medicamentoList.removeAt(index);
    });
  }
}
