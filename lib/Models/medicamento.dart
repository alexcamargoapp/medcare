class Medicamento {
  int _id;
  String _nome;
  String _prescricao;
  String _data;

  Medicamento(this._nome, this._data, [this._prescricao]);

  Medicamento.withId(this._id, this._nome, this._data, [this._prescricao]);

  int get id => _id;

  String get nome => _nome;

  String get prescricao => _prescricao;

  String get data => _data;

  set nome(String novoNome) {
    if (novoNome.length <= 255) {
      this._nome = novoNome;
    }
  }

  set prescricao(String novaPrescricao) {
    if (novaPrescricao.length <= 255) {
      this._prescricao = novaPrescricao;
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
    map['prescricao'] = _prescricao;
    map['data'] = _data;

    return map;
  }

  // Extract a Note object from a Map object
  Medicamento.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._nome = map['nome'];
    this._prescricao = map['prescricao'];
    this._data = map['data'];
  }
}
