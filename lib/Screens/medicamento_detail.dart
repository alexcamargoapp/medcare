import 'package:MedCare/Utils/dialogs.dart';
import 'package:flutter/material.dart';
import '../Models/medicamento.dart';
import '../Utils/database_helper.dart';
import 'package:intl/intl.dart';

class MedicamentoDetail extends StatefulWidget {
  final String appBarTitle;
  final Medicamento medicamento;

  MedicamentoDetail(this.medicamento, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return MedicamentoDetailState(this.medicamento, this.appBarTitle);
  }
}

class MedicamentoDetailState extends State<MedicamentoDetail> {
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Medicamento medicamento;

  MedicamentoDetailState(this.medicamento, this.appBarTitle);

  TextEditingController nomeController = TextEditingController();
  TextEditingController prescricaoController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  FocusScopeNode _focusScopeNode = FocusScopeNode();
  void _handleSubmitted(String value) {
    _focusScopeNode.nextFocus();
  }

  @override
  Widget build(BuildContext context) {
    nomeController.text = medicamento.nome;
    prescricaoController.text = medicamento.prescricao;

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
            padding: EdgeInsets.only(top: 15.0, left: 8.0, right: 20.0),
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
              style: _textStyle,
              controller: nomeController,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.label_important),
                  labelStyle: _textStyle,
                  labelText: ' Nome medicamento ',
                  hintText: 'digite o nome',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              maxLength: 50,
              validator: _validarNome,
              onSaved: (String val) {
                medicamento.nome = val.toUpperCase();
              }),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: TextFormField(
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            style: _textStyle,
            controller: prescricaoController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.note),
              labelStyle: _textStyle,
              labelText: ' Prescrição ',
              hintText: 'digite a prescrição',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            maxLength: 200,
            onSaved: (String val) {
              medicamento.prescricao = val;
            },
            validator: _validarPrescricao,
          ),
        ),
        SizedBox(height: 15.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            //Expanded(
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
            //),
          ],
        ),
      ],
    );
  }

  String _validarNome(String value) {
    if (value.length == 0) {
      return "Informe o nome do medicamento";
    }
    return null;
  }

  String _validarPrescricao(String value) {
    if (value.length == 0) {
      return "Informe a prescrição";
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
    medicamento.data = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (medicamento.id != null) {
      result = await helper.updateMedicamento(medicamento);
    } else {
      result = await helper.insertMedicamento(medicamento);
    }
    _moveToLastScreen();

    if (result != 0) {
      // Success
      Dialogs.showAlertDialog(
          'Status', 'Medicamento salvo com Sucesso', context);
    } else {
      // Failure
      Dialogs.showAlertDialog(
          'Atenção', 'Falha ao salvar Medicamento', context);
    }
  }
}
