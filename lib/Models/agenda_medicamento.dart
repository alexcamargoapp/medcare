class AgendaMedicamento {
  int _agendaid;
  int _medicamentoid;

  AgendaMedicamento(this._agendaid, this._medicamentoid);

  int get agendaid => _agendaid;
  int get medicamentoid => _medicamentoid;

  set agendaid(int newAgendaId) {
    this._agendaid = newAgendaId;
  }

  set medicamentoid(int newMedicamentoId) {
    this._medicamentoid = newMedicamentoId;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['agendaid'] = _agendaid;
    map['medicamentoid'] = _medicamentoid;
    return map;
  }

  // Extract a Note object from a Map object
  AgendaMedicamento.fromMapObject(Map<String, dynamic> map) {
    this._agendaid = map['agendaid'];
    this._medicamentoid = map['medicamentoid'];
  }
}
