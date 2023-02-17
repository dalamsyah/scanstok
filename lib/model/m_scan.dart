

class ScanModel {
  int _idstokcount = 0;
  String _item_code = "";
  String _sn = "";
  String _sn2 = "";
  int _scan = 0;
  String _created_at = "";
  String _updated_at = "";

  // konstruktor versi 1
  ScanModel(this._sn, this._sn2);

  // konstruktor versi 2: konversi dari Map ke Scan
  ScanModel.fromMap(Map<String, dynamic> map) {
    this._idstokcount = map['idstokcount'];
    this._item_code = map['item_code'];
    this._sn = map['sn'];
    this._sn2 = map['sn2'];
    this._scan = map['scan'];
  }
  //getter dan setter (mengambil dan mengisi data kedalam object)
  // getter
  int get id => _idstokcount;
  String get sn => _sn;
  String get sn2 => _sn2;
  int get scan => _scan;

  // setter
  set sn(String value) {
    sn = value;
  }

  set sn2(String value) {
    sn2 = value;
  }

  // konversi dari Scan ke Map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['idstokcount'] = this._idstokcount;
    map['item_code'] = this._item_code;
    map['sn'] = _sn;
    map['sn2'] = _sn2;
    map['scan'] = _scan;
    return map;
  }

}