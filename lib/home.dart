import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:MedCare/Screens/paciente_list.dart';
import 'package:MedCare/Screens/medicamento_list.dart';
import 'package:MedCare/Screens/agenda_list.dart';

import 'Notifications/NotificationPlugin.dart';
import 'Utils/database_helper.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.blue,
        ),
        title: Text(
          '',
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomCenter,
                //child: Center(
                child: Text(
                  'MedCare',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 45,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                //),
                //color: Colors.purple,
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                alignment: Alignment.center,
                //child: Center(
                child: Image.asset(
                  'assets/images/icon.png',
                  scale: 2,
                ),
                //),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                //child: Center(
                child: Text(
                  'Agenda de Medicamentos',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                //),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Container(
                  alignment: Alignment.bottomRight,
                  child: Text('MedCare',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                      ))),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/prescricao.jpg'),
                      fit: BoxFit.cover)),
            ),
            ListTile(
              leading: Icon(
                Icons.person,
                size: 40,
              ),
              title: Text('Paciente',
                  style: TextStyle(fontSize: 25, color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PacienteList()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.local_hospital,
                size: 40,
              ),
              title: Text('Medicamentos',
                  style: TextStyle(fontSize: 25, color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MedicamentoList()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.alarm,
                size: 40,
              ),
              title: Text('Prescrição Médica',
                  style: TextStyle(fontSize: 25, color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AgendaList()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.help,
                size: 40,
              ),
              title: Text('Ajuda',
                  style: TextStyle(fontSize: 25, color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                size: 40,
              ),
              title: Text('Home',
                  style: TextStyle(fontSize: 25, color: Colors.black)),
              onTap: () {
                Navigator.pop(context, true);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.data_usage,
                size: 40,
              ),
              title: Text('Load Data',
                  style: TextStyle(fontSize: 25, color: Colors.black)),
              onTap: () async {
                await databaseHelper.loadData();
                await notificationPlugin.cancelAllNotification();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                size: 40,
              ),
              title: Text('Sair',
                  style: TextStyle(fontSize: 25, color: Colors.black)),
              onTap: () {
                pop(animated: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> pop({bool animated}) async {
    await SystemChannels.platform
        .invokeMethod<void>('SystemNavigator.pop', animated);
  }
}
