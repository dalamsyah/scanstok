
import 'package:scanstock/helper/DBHelper.dart';
import 'package:scanstock/model/m_scan.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

class ScanService {

  // String url = 'http://192.168.56.1/scan_barcode_stok_api/public/scan';
  String url = 'http://192.168.0.102/scan_barcode_stok_api/public/scan';


  List<ScanModel> listScan = [];
  bool isLoading = false;

  Future<List<ScanModel>> getScanList() async {

    isLoading = true;

    SharedPreferences localStorage = await SharedPreferences.getInstance();

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      var list = data['data'] as List;

      listScan = list.map((data) => ScanModel.fromMap(data) ).toList();

      DbHelper.delete();
      listScan.forEach((element) {
        DbHelper.createItem(element);
      });

      isLoading = false;

      return listScan;
    } else {
      isLoading = false;
      throw Exception('Failed to get list scan.');
    }

  }

  Future<String> postList() async {

    List<ScanModel> list = await DbHelper.getListToUpload();
    final response = await http.post(Uri.parse(url), body: {
      'list': jsonEncode(encondeToJson(list)),
    });

    if (response.statusCode == 201) {
      return 'Success update data';
    } else if (response.statusCode == 200) {
      return 'Failed update all data';
    } else {
      throw Exception('Failed to post list.');
    }
  }

  List encondeToJson(List<ScanModel> list) {
    List jsonList = [];
    list.map((item) => jsonList.add(item.toMap())).toList();
    return jsonList;
  }

}