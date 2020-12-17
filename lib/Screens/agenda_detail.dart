import 'package:MedCare/Utils/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MedCare/Notifications/NotificationPlugin.dart';
import '../Models/agenda.dart';
import '../Utils/database_helper.dart';

class AgendaDetail extends StatefulWidget {
  final String appBarTitle;
  final Agenda agenda;
  AgendaDetail(this.agenda, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return AgendaDetailState(this.agenda, this.appBarTitle);
  }
}

class AgendaDetailState extends State<AgendaDetail> {
  DatabaseHelper helper = DatabaseHelper();
  //NotificationManager notification = NotificationManager();

  String appBarTitle;
  Agenda agenda;
  AgendaDetailState(this.agenda, this.appBarTitle);

  TimeOfDay selectedTime = TimeOfDay.now();

  TextEditingController horarioController = TextEditingController();
  TextEditingController tituloController = TextEditingController();

  //GlobalKey<FormState> _key =  GlobalKey();
  final _formKey = GlobalKey<FormState>();

  FocusScopeNode _focusScopeNode = FocusScopeNode();
  void _handleSubmitted(String value) {
    _focusScopeNode.nextFocus();
  }

  @override
  Widget build(BuildContext context) {
    horarioController.text = agenda.horario;
    tituloController.text = agenda.titulo;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _moveToLastScreen();
            }),
      ),
      body: FocusScope(
        node: _focusScopeNode,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 15.0, left: 8.0, right: 20.0),
            child: Form(
              key: _formKey,
              //autovalidate: _validate,
              child: _formUI(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formUI() {
    TextStyle _textStyle = Theme.of(context).textTheme.headline6;
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: TextFormField(
              style: _textStyle,
              controller: tituloController,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.label_important),
                  labelStyle: _textStyle,
                  labelText: ' Título da Prescrição ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              maxLength: 30,
              validator: _validarTitulo,
              onSaved: (String val) {
                agenda.titulo = val;
              }),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: TextFormField(
              readOnly: true,
              style: _textStyle,
              controller: horarioController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.alarm),
                labelStyle: _textStyle,
                labelText: ' Horário da Prescrição ',
                hintText: 'informe o horário',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              onSaved: (String val) {
                agenda.horario = val;
              },
              validator: _validarHorario,
              onTap: () {
                selectTime();
              }),
        ),
        SizedBox(height: 15.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Visibility(
              child: Row(
                children: [
                  Text(
                    'Ativar Alerta',
                    style: _textStyle,
                  ),
                  Switch(
                    value: (agenda.ativa == 1) ? true : false,
                    onChanged: (value) {
                      (value)
                          ? _sendForm()
                          : _disableScheduleNotification(agenda.id);
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                ],
              ),
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: (agenda.id == null) ? false : true,
            ),
            RaisedButton.icon(
                icon: Icon(Icons.check),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onPressed: _sendForm,
                color: Theme.of(context).primaryColorDark,
                textColor: Theme.of(context).primaryColorLight,
                label: Text(
                  'Salvar',
                  textScaleFactor: 1.5,
                )),
          ],
        ),
      ],
    );
  }

  String _validarTitulo(String value) {
    if (value.length == 0) {
      return "Informe o Título";
    }
    return null;
  }

  String _validarHorario(String value) {
    if (value.length == 0) {
      return "Informe o Horário";
    }
    return null;
  }

  _sendForm() async {
    if (_formKey.currentState.validate()) {
      // Sem erros na validação
      _formKey.currentState.save();
      setState(() {
        _save(context);
      });
    }
  }

  void _moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void _save(BuildContext context) async {
    agenda.data = DateFormat.yMMMd().format(DateTime.now());
    agenda.ativa = 1;
    int result;
    if (agenda.id != null) {
      result = await helper.updateAgenda(agenda);
      _enableScheduleNotification(agenda.id);
    } else {
      result = await helper.insertAgenda(agenda);
      _enableScheduleNotification(result);
    }
    setState(() {
      _moveToLastScreen();
    });

    if (result != 0) {
      // Success
      Dialogs.showAlertDialog(
          'Status',
          'Prescrição salva com sucesso e Alerta diário ativado para: ' +
              agenda.horario +
              'h',
          context);
    } else {
      // Failure
      Dialogs.showAlertDialog('Atenção', 'Falha ao salvar Prescrição', context);
    }
  }

  Future<void> selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    if (time != null) {
      horarioController.text = time.format(context);
    }
  }

  void _enableScheduleNotification(int notificationID) {
    TimeOfDay _startTime = TimeOfDay(
        hour: int.parse(agenda.horario.split(":")[0]),
        minute: int.parse(agenda.horario.split(":")[1]));
    notificationPlugin.cancelNotification(notificationID);
    notificationPlugin.showDailyAtTime(
        notificationID,
        agenda.titulo,
        'Clique aqui para visualizar',
        _startTime.hour,
        _startTime.minute,
        notificationID.toString());
  }

  void _disableScheduleNotification(int notificationID) async {
    int result;
    agenda.ativa = 0;

    result = await helper.updateAgenda(agenda);

    setState(() {
      _moveToLastScreen();
    });

    if (result != 0) {
      notificationPlugin.cancelNotification(notificationID);
      Dialogs.showAlertDialog('Status', 'Alerta desativado', context);
    } else {
      // Failure
      Dialogs.showAlertDialog('Atenção', 'Falha ao desativar Alerta', context);
    }
  }
}
