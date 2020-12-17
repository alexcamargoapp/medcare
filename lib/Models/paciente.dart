class Paciente {
  int _id;
  String _nome;
  String _diagnostico;
  String _data;

  Paciente(this._nome, this._data, [this._diagnostico]);

  Paciente.withId(this._id, this._nome, this._data, this._diagnostico);

  int get id => _id;

  String get nome => _nome;

  String get diagnostico => _diagnostico;

  String get data => _data;

  set nome(String novoNome) {
    if (novoNome.length <= 255) {
      this._nome = novoNome;
    }
  }

  set diagnostico(String novoDiagnostico) {
    if (novoDiagnostico.length <= 255) {
      this._diagnostico = novoDiagnostico;
    }
  }

  set data(String novaData) {
    this._data = novaData;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['nome'] = _nome;
    map['diagnostico'] = _diagnostico;
    map['data'] = _data;

    return map;
  }

  // Extract a Note object from a Map object
  Paciente.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._nome = map['nome'];
    this._diagnostico = map['diagnostico'];
    this._data = map['data'];
  }
}
