class ViewAgendaMedicamento {
  int _agendaid;
  int _medicamentoid;
  String _nome;
  String _prescricao;

  ViewAgendaMedicamento(this._agendaid, this._medicamentoid, this._nome,
      [this._prescricao]);

  int get agendaid => _agendaid;

  int get medicamentoid => _medicamentoid;

  String get nome => _nome;

  String get prescricao => _prescricao;

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['agendaid'] = _agendaid;
    map['medicamentoid'] = _medicamentoid;
    map['nome'] = _nome;
    map['prescricao'] = _prescricao;

    return map;
  }

  // Extract a Note object from a Map object
  ViewAgendaMedicamento.fromMapObject(Map<String, dynamic> map) {
    this._agendaid = map['agendaid'];
    this._medicamentoid = map['medicamentoid'];
    this._nome = map['nome'];
    this._prescricao = map['prescricao'];
  }
}
