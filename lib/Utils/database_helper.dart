import 'package:MedCare/Models/view_agenda_medicamento.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../Models/paciente.dart';
import '../Models/medicamento.dart';
import '../Models/agenda.dart';
import '../Models/agenda_medicamento.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  // Table Pacientes
  String tablePacientes = 'pacientes';
  String pacienteId = 'id';
  String pacienteNome = 'nome';
  String pacienteDiagnostico = 'diagnostico';
  String pacienteData = 'data';

  // Table Medicamentos
  String tableMedicamentos = 'medicamentos';
  String medicamentoId = 'id';
  String medicamentoNome = 'nome';
  String medicamentoPrescricao = 'prescricao';
  String medicamentoData = 'data';

  // Table Agenda de Alertas
  String tableAgendas = 'agendas';
  String agendaId = 'id';
  String agendaHorario = 'horario';
  String agendaDiasSemana = 'dias_semana';
  String agendaTipo = 'tipo';
  String agendaTitulo = 'titulo';
  String agendaDescricao = 'descricao';
  String agendaAtiva = 'ativa';
  String agendaData = 'data';

  // Table AgendaMedicamento
  String tableAgendaMedicamento = 'agenda_medicamento';
  String idAgenda = 'agendaid';
  String idMedicamento = 'medicamentoid';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'database.db';

    // Open/create the database at a given path
    var hrDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return hrDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tablePacientes($pacienteId INTEGER PRIMARY KEY AUTOINCREMENT, $pacienteNome TEXT, '
        '$pacienteDiagnostico TEXT, $pacienteData TEXT)');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tableMedicamentos($medicamentoId INTEGER PRIMARY KEY AUTOINCREMENT, $medicamentoNome TEXT, '
        '$medicamentoPrescricao TEXT, $medicamentoData TEXT)');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $tableAgendas($agendaId INTEGER PRIMARY KEY AUTOINCREMENT, $agendaHorario TEXT, '
        '$agendaDiasSemana TEXT, $agendaTipo TEXT, $agendaTitulo TEXT, $agendaDescricao TEXT, $agendaAtiva INTEGER,  $agendaData TEXT)');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $tableAgendaMedicamento($idAgenda INTEGER, $idMedicamento INTEGER)');

    await db.execute('''CREATE VIEW v_agenda_medicamento 
            AS 
            SELECT
              agenda_medicamento.agendaid,
              agenda_medicamento.medicamentoid,
              medicamentos.nome,
              medicamentos.prescricao
            FROM
              agendas
            INNER JOIN agenda_medicamento ON agenda_medicamento.agendaid = agendas.id
            INNER JOIN medicamentos ON agenda_medicamento.medicamentoid = medicamentos.id;''');
  }

  // Fetch Operation: Get all paciente objects from database
  Future<List<Map<String, dynamic>>> getPacienteMapList() async {
    Database db = await this.database;

    // var result = await db.rawQuery('SELECT * FROM $pacienteTable order by $colTitle ASC');
    var result = await db.query(tablePacientes, orderBy: '$pacienteNome ASC');
    return result;
  }

  // Insert Operation: Insert a paciente object to database
  Future<int> insertPaciente(Paciente paciente) async {
    Database db = await this.database;
    var result = await db.insert(tablePacientes, paciente.toMap());
    return result;
  }

  // Update Operation: Update a paciente object and save it to database
  Future<int> updatePaciente(Paciente paciente) async {
    var db = await this.database;
    var result = await db.update(tablePacientes, paciente.toMap(),
        where: '$pacienteId = ?', whereArgs: [paciente.id]);
    return result;
  }

  Future<int> updatePacienteCompleted(Paciente paciente) async {
    var db = await this.database;
    var result = await db.update(tablePacientes, paciente.toMap(),
        where: '$pacienteId = ?', whereArgs: [paciente.id]);
    return result;
  }

  // Delete Operation: Delete a paciente object from database
  Future<int> deletePaciente(int id) async {
    var db = await this.database;
    int result = await db
        .rawDelete('DELETE FROM $tablePacientes WHERE $pacienteId = $id');
    return result;
  }

  // Get number of paciente objects in database
  Future<int> getPacienteCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $tablePacientes');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'paciente List' [ List<Paciente> ]
  Future<List<Paciente>> getPacienteList() async {
    var pacienteMapList =
        await getPacienteMapList(); // Get 'Map List' from database
    int count =
        pacienteMapList.length; // Count the number of map entries in db table

    List<Paciente> pacienteList = List<Paciente>();
    // For loop to create a 'paciente List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      pacienteList.add(Paciente.fromMapObject(pacienteMapList[i]));
    }

    return pacienteList;
  }

  // Medicamento
  // Fetch Operation: Get all medicamentos objects from database
  Future<List<Map<String, dynamic>>> getMedicamentoMapList() async {
    Database db = await this.database;

    var result =
        await db.query(tableMedicamentos, orderBy: '$medicamentoNome ASC');
    return result;
  }

  // Insert Operation: Insert a medicamento object to database
  Future<int> insertMedicamento(Medicamento medicamento) async {
    Database db = await this.database;
    var result = await db.insert(tableMedicamentos, medicamento.toMap());
    return result;
  }

  // Update Operation: Update a medicamento object and save it to database
  Future<int> updateMedicamento(Medicamento medicamento) async {
    var db = await this.database;
    var result = await db.update(tableMedicamentos, medicamento.toMap(),
        where: '$medicamentoId = ?', whereArgs: [medicamento.id]);
    return result;
  }

  Future<int> updateMedicamentoCompleted(Medicamento medicamento) async {
    var db = await this.database;
    var result = await db.update(tableMedicamentos, medicamento.toMap(),
        where: '$medicamentoId = ?', whereArgs: [medicamento.id]);
    return result;
  }

  // Delete Operation: Delete a medicamento object from database
  Future<int> deleteMedicamento(int id) async {
    var db = await this.database;
    int result = await db
        .rawDelete('DELETE FROM $tableMedicamentos WHERE $medicamentoId = $id');
    return result;
  }

  // Get number of medicamento objects in database
  Future<int> getMedicamentoCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $tableMedicamentos');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'medicamento List' [ List<Medicamento> ]
  Future<List<Medicamento>> getMedicamentoList() async {
    var medicamentoMapList =
        await getMedicamentoMapList(); // Get 'Map List' from database
    int count = medicamentoMapList
        .length; // Count the number of map entries in db table

    List<Medicamento> medicamentoList = List<Medicamento>();
    // For loop to create a 'paciente List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      medicamentoList.add(Medicamento.fromMapObject(medicamentoMapList[i]));
    }

    return medicamentoList;
  }

  // Agenda
  // Fetch Operation: Get all agendas objects from database
  Future<List<Map<String, dynamic>>> getAgendaMapList() async {
    Database db = await this.database;

    // var result = await db.rawQuery('SELECT * FROM $agenda order by $agendaHorario ASC');
    var result = await db.query(tableAgendas, orderBy: '$agendaHorario ASC');
    return result;
  }

  // Insert Operation: Insert a agenda object to database
  Future<int> insertAgenda(Agenda agenda) async {
    Database db = await this.database;
    var result = await db.insert(tableAgendas, agenda.toMap());
    return result;
  }

  // Update Operation: Update a agenda object and save it to database
  Future<int> updateAgenda(Agenda agenda) async {
    var db = await this.database;
    var result = await db.update(tableAgendas, agenda.toMap(),
        where: '$agendaId = ?', whereArgs: [agenda.id]);
    return result;
  }

  Future<int> updateAgendaCompleted(Agenda agenda) async {
    var db = await this.database;
    var result = await db.update(tableAgendas, agenda.toMap(),
        where: '$agendaId = ?', whereArgs: [agenda.id]);
    return result;
  }

  // Delete Operation: Delete a agenda object from database
  Future<int> deleteAgenda(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $tableAgendas WHERE $agendaId = $id');
    return result;
  }

  // Get number of agenda objects in database
  Future<int> getAgendaCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $tableAgendas');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get number of agenda objects by id in database
  Future<Agenda> getAgendaById(int id) async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT * FROM agendas WHERE id=?', [id]);
    if (result.length > 0) {
      return Agenda.fromMapObject(result[0]);
    }
    return null;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'agenda List' [ List<Agenda> ]
  Future<List<Agenda>> getAgendaList() async {
    var agendaMapList =
        await getAgendaMapList(); // Get 'Map List' from database
    int count =
        agendaMapList.length; // Count the number of map entries in db table

    List<Agenda> agendaList = List<Agenda>();
    // For loop to create a 'agenda List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      agendaList.add(Agenda.fromMapObject(agendaMapList[i]));
    }

    return agendaList;
  }

  // Insert Operation: Insert a agenda_medicamento object to database
  Future<int> insertAgendaMedicamento(
      // ignore: non_constant_identifier_names
      AgendaMedicamento agenda_medicamento) async {
    Database db = await this.database;
    var result =
        await db.insert(tableAgendaMedicamento, agenda_medicamento.toMap());
    return result;
  }

  // Delete Operation: Delete a agenda_medicament by AgendaId and MedicamentoId object from database
  Future<int> deleteAgendaMedicamento(int agendaid, int medicamentoid) async {
    var db = await this.database;
    int result = await db.rawDelete(
        'DELETE FROM $tableAgendaMedicamento WHERE $idAgenda = $agendaid AND $idMedicamento = $medicamentoid');
    return result;
  }

// Delete Operation: Delete a agenda_medicamento by AgendaId and MedicamentoId object from database
  Future<int> deleteAgendaMedicamentoByAgendaId(int agendaid) async {
    var db = await this.database;
    int result = await db.rawDelete(
        'DELETE FROM $tableAgendaMedicamento WHERE $idAgenda = $agendaid');
    return result;
  }

  // Delete Operation: Delete a agenda_medicamento by MedicamentoId object from database
  Future<int> deleteAgendaMedicamentoByMedicamentoId(int medicamentoid) async {
    var db = await this.database;
    int result = await db.rawDelete(
        'DELETE FROM $tableAgendaMedicamento WHERE $idMedicamento = $medicamentoid');
    return result;
  }

  // View AgendaMedicamento
  // Fetch Operation: Get all view agenda_medicamento objects from database
  Future<List<Map<String, dynamic>>> getViewAgendaMedicamentoMapList(
      int agendaID) async {
    Database db = await this.database;

    var result = await db.query('v_agenda_medicamento',
        where: 'agendaid = ?', whereArgs: [agendaID], orderBy: ' nome ASC');
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'v_agenda_medicamento List' [ List<Agenda> ]
  Future<List<ViewAgendaMedicamento>> getViewAgendaMedicamentoList(
      int agendaID) async {
    var viewAgendaMedicamentoMapList = await getViewAgendaMedicamentoMapList(
        agendaID); // Get 'Map List' from database
    int count = viewAgendaMedicamentoMapList
        .length; // Count the number of map entries in db table

    List<ViewAgendaMedicamento> viewAgendaMedicamentoList =
        List<ViewAgendaMedicamento>();
    // For loop to create a 'agenda List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      viewAgendaMedicamentoList.add(
          ViewAgendaMedicamento.fromMapObject(viewAgendaMedicamentoMapList[i]));
    }

    return viewAgendaMedicamentoList;
  }

  Future loadData() async {
    var db = await this.database;

    //Table agenda_medicamento
    await db.rawDelete("DELETE FROM agenda_medicamento");

    //Table Agendas
    await db.rawDelete("DELETE FROM agendas");
    await db.rawInsert(
        'INSERT INTO agendas(horario, titulo, ativa) VALUES("00:00", "Administrar Medicação", 0)');
    await db.rawInsert(
        'INSERT INTO agendas(horario, titulo, ativa) VALUES("06:00", "Administrar Medicação", 0)');
    await db.rawInsert(
        'INSERT INTO agendas(horario, titulo, ativa) VALUES("12:00", "Administrar Medicação", 0)');
    await db.rawInsert(
        'INSERT INTO agendas(horario, titulo, ativa) VALUES("14:00", "Administrar Medicação", 0)');
    await db.rawInsert(
        'INSERT INTO agendas(horario, titulo, ativa) VALUES("18:00", "Administrar Medicação", 0)');
    await db.rawInsert(
        'INSERT INTO agendas(horario, titulo, ativa) VALUES("22:00", "Administrar Medicação", 0)');

    //Table Medicamentos
    await db.rawDelete("DELETE FROM medicamentos");
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("BACLOFENO","Tomar 2 Comprimidos de 6/6 horas")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("DOMPERIDONA","Tomar 1 Comprimido antes das refeições")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("CLORIDRATO DE CICLOBENZAPRINA","Tomar 1 Comprimido ao dia")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("RETEMIC","Tomar 1 Comprimido de 8/8 horas")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("DIPIRONA","Tomar 1 Comprimido de 6/6 horas somente em caso de dor")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("VISICARE/IMPERE","Tomar 2 Comprimidos de 5mg ou 1 comprimido de 10mg antes de dormir")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("OMEPRAZOL","Tomar 1 Capsula de 12/12 horas")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("RELAXANTE MUSCULAR","Tomar 1 Comprimido de 8/8 horas")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("LACTULONA","Tomar 15 ml. de 6/6 horas")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("SIMETICONA","Tomar 40 gotas ou 1 Comprimido de 8/8 horas")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("VITAMINA D","Tomar 35 gotas uma vez ao dia")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("OSTEOFAR","Tomar 1 Comprimido (POR SEMANA) de manhã em jejum permacer sentado por 1h.")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("CÁLCIO","Tomar 1 Capsula uma vez por dia à noite")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("CIPROFIBRATO","Tomar 1 Comprimido uma vez ao dia à noite")');
    await db.rawInsert(
        'INSERT INTO medicamentos(nome, prescricao) VALUES("OLEO MINERAL","Tomar 15ml uma vez ao dia ")');

    //Table Paciente
    await db.rawDelete("DELETE FROM pacientes");
    await db.rawInsert(
        'INSERT INTO pacientes(nome, diagnostico) VALUES("ALEX SANDRO FRANCISCO DE CAMARGO","Tetraplegia - Lesão Medular C5 por Acidente automobilístio em 15-OUT-2014")');

    //Table agenda_medicamento
    await db.rawDelete("DELETE FROM agenda_medicamento");
  }
}
