class Agenda {
  int _id;
  String _horario;
  // ignore: non_constant_identifier_names
  String _dias_semana;
  String _tipo;
  String _titulo;
  String _descricao;
  int _ativa;
  String _data;

  Agenda(this._horario, this._dias_semana, this._tipo, this._titulo,
      this._descricao, this._ativa, this._data);
  Agenda.withId(this._id, this._horario, this._dias_semana, this._tipo,
      this._titulo, this._descricao, this._ativa, this._data);

  int get id => _id;
  String get horario => _horario;
  // ignore: non_constant_identifier_names
  String get dias_semana => _dias_semana;
  String get tipo => _tipo;
  String get titulo => _titulo;
  String get descricao => _descricao;
  int get ativa => _ativa;
  String get data => _data;

  set horario(String novoHorario) {
    if (novoHorario.length <= 255) {
      this._horario = novoHorario;
    }
  }

  // ignore: non_constant_identifier_names
  set dias_semana(String novoDiasSemana) {
    if (novoDiasSemana.length <= 255) {
      this._dias_semana = novoDiasSemana;
    }
  }

  set tipo(String novoTipo) {
    if (novoTipo.length <= 255) {
      this._tipo = novoTipo;
    }
  }

  set titulo(String novoTitulo) {
    if (novoTitulo.length <= 255) {
      this._titulo = novoTitulo;
    }
  }

  set descricao(String novaDescricao) {
    if (novaDescricao.length <= 255) {
      this._descricao = novaDescricao;
    }
  }

  set ativa(int novaAtiva) {
    this._ativa = novaAtiva;
  }

  set data(String novaData) {
    if (novaData.length <= 255) {
      this._data = novaData;
    }
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['horario'] = _horario;
    map['dias_semana'] = _dias_semana;
    map['tipo'] = _tipo;
    map['titulo'] = _titulo;
    map['descricao'] = _descricao;
    map['ativa'] = _ativa;
    map['data'] = _data;

    return map;
  }

  // Extract a Note object from a Map object
  Agenda.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._horario = map['horario'];
    this._dias_semana = map['diassemana'];
    this._tipo = map['tipo'];
    this._titulo = map['titulo'];
    this._descricao = map['descricao'];
    this._ativa = map['ativa'];
    this._data = map['data'];
  }
}
