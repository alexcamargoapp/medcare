import 'package:MedCare/Utils/dialogs.dart';
import 'package:flutter/material.dart';
import '../Models/paciente.dart';
import '../Utils/database_helper.dart';
import 'package:intl/intl.dart';

class PacienteDetail extends StatefulWidget {
  final String appBarTitle;
  final Paciente paciente;

  PacienteDetail(this.paciente, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return PacienteDetailState(this.paciente, this.appBarTitle);
  }
}

class PacienteDetailState extends State<PacienteDetail> {
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Paciente paciente;

  PacienteDetailState(this.paciente, this.appBarTitle);

  TextEditingController nomeController = TextEditingController();
  TextEditingController diagnosticoController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  FocusScopeNode _focusScopeNode = FocusScopeNode();
  void _handleSubmitted(String value) {
    _focusScopeNode.nextFocus();
  }

  @override
  Widget build(BuildContext context) {
    nomeController.text = paciente.nome;
    diagnosticoController.text = paciente.diagnostico;

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
            margin: EdgeInsets.only(top: 15.0, left: 8, right: 20.0),
            child: Form(
              key: _formKey,
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
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 6, //Normal textInputField will be displayed
              style: _textStyle,
              controller: nomeController,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelStyle: _textStyle,
                  labelText: ' Nome paciente ',
                  hintText: 'digite o nome',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              maxLength: 100,
              validator: _validarNome,
              onSaved: (String val) {
                paciente.nome = val;
              }),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: TextFormField(
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 10,
            style: _textStyle,
            controller: diagnosticoController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.note),
              labelStyle: _textStyle,
              labelText: ' Diagnostico ',
              hintText: 'digite o diagnostico',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            maxLength: 255,
            onSaved: (String val) {
              paciente.diagnostico = val;
            },
            validator: _validarDiagnostico,
          ),
        ),
        SizedBox(height: 15.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
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

  String _validarNome(String value) {
    if (value.length == 0) {
      return "Informe o nome do paciente";
    }
    return null;
  }

  String _validarDiagnostico(String value) {
    if (value.length == 0) {
      return "Informe o diagnostico";
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
    paciente.data = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (paciente.id != null) {
      result = await helper.updatePaciente(paciente);
    } else {
      result = await helper.insertPaciente(paciente);
    }
    _moveToLastScreen();

    if (result != 0) {
      // Success
      Dialogs.showAlertDialog('Status', 'Paciente salvo com Sucesso', context);
    } else {
      // Failure
      Dialogs.showAlertDialog('Atenção', 'Falha ao salvar Paciente', context);
    }
  }
}
