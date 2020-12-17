import 'dart:async';
import 'package:MedCare/home.dart';
import 'package:MedCare/notifications/NotificationPlugin.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import '../Models/agenda.dart';
import '../Utils/database_helper.dart';
import '../main.dart';
import 'agenda_detail.dart';
import 'agenda_medicamento_list.dart';

class AgendaList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AgendaListState();
  }
}

class AgendaListState extends State<AgendaList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Agenda> agendaList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (agendaList == null) {
      agendaList = List<Agenda>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            navigateToHome();
          },
          child: Icon(
            Icons.arrow_back, // add custom icons also
          ),
        ),
        title: Text('Prescrição Médica'),
      ),
      body: getAgendaListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(
              Agenda('', '', '', 'Administrar Medicação', '', 1, ''),
              'Criando nova Prescrição');
        },
        tooltip: 'Nova Prescrição',
        child: Icon(Icons.add),
      ),
    );
  }

  Column getAgendaListView() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: count,
            itemBuilder: (BuildContext context, int position) {
              return Dismissible(
                key: ValueKey(agendaList[position]),
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
                    horizontal: 10,
                    vertical: 4,
                  ),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) {
                  return showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: Text('Tem certeza?'),
                            content: Text(
                              'Quer remover a prescrição das ' +
                                  this.agendaList[position].horario +
                                  'h - ' +
                                  this.agendaList[position].titulo +
                                  ' ?',
                            ),
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
                  // Remove the item from the data sourc
                  _delete(context, this.agendaList[position]);
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          onTap: () => navigateToAgendaMedicamento(
                              this.agendaList[position]),
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
                                this.agendaList[position].horario,
                                style: TextStyle(
                                    fontSize: 19,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          title: Text(this.agendaList[position].titulo,
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            (this.agendaList[position].ativa == 1)
                                ? 'Alerta Diário: Ativado'
                                : 'Alerta: Desativado',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              (this.agendaList[position].ativa == 1)
                                  ? Icon(
                                      Icons.notifications_active,
                                      color: Colors.green,
                                      size: 30,
                                    )
                                  : Icon(
                                      Icons.notifications_off,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            ButtonBar(
                              alignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  child: const Text('MEDICAMENTOS'),
                                  onPressed: () {
                                    navigateToAgendaMedicamento(
                                        this.agendaList[position]);
                                  },
                                ),
                              ],
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.start,
                              children: <Widget>[
                                FlatButton(
                                  child: const Text('EDITAR'),
                                  onPressed: () {
                                    navigateToDetail(this.agendaList[position],
                                        'Editar Prescrição');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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

  void _delete(BuildContext context, Agenda agenda) async {
    //Delete relatioship with Medicamentos on table agenda_medicamento
    await databaseHelper.deleteAgendaMedicamentoByAgendaId(agenda.id);

    int result = await databaseHelper.deleteAgenda(agenda.id);
    if (result != 0) {
      //Cancel Agenda's Notification
      notificationPlugin.cancelNotification(agenda.id);

      _showSnackBar(context, 'Prescrição Excluída com Sucesso');
      updateListView();
    } else
      _showSnackBar(context, 'Falha ao excluir Prescrição');
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Agenda agenda, String nome) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AgendaDetail(agenda, nome);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void navigateToAgendaMedicamento(Agenda agenda) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AgendaMedicamentoList(agenda);
    }));

    if (result == true) {}
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Agenda>> agendaListFuture = databaseHelper.getAgendaList();
      agendaListFuture.then((agendaList) {
        setState(() {
          this.agendaList = agendaList;
          this.count = agendaList.length;
        });
      });
    });
  }

  void navigateToHome() async {
    await MyApp.navigatorKey.currentState
        .push(MaterialPageRoute(builder: (context) => Home()));
  }
}
