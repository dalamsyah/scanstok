
import 'package:scanstock/helper/DBHelper.dart';
import 'package:scanstock/model/m_scan.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ScanService {

  String baseUrl = 'http://192.168.56.1/scanbarcode/api.php';
  // String baseUrl = 'http://192.168.0.102/scan_barcode_stok_api/api_stock/api.php';
  // String url = 'http://172.20.10.11/scan_barcode_stok_api/public/scan';


  List<ScanModel> listScan = [];
  bool isLoading = false;

  Future<List<ScanModel>> getScanList() async {

    isLoading = true;

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String url = localStorage.getString("url") ?? baseUrl;

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      var list = data['data'] as List;

      listScan = list.map((data) => ScanModel.fromMap2(data) ).toList();

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

  Future<String> postList(List<ScanModel> list) async {

    SharedPreferences localStorage = await SharedPreferences.getInstance();

    String url = localStorage.getString("url") ?? baseUrl;
    final response = await http.post(Uri.parse(url), body: {
      'list': jsonEncode(encondeToJson(list)),
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      var list = data['data'] as List;
      List<ScanModel> result = list.map((data) => ScanModel.fromMap2(data) ).toList();

      if (result.isNotEmpty) {
        for (ScanModel scanModel in result) {
          DbHelper.updateStatusUpload(scanModel.id);
        }
      }

      return 'Success update data';
    }
    // else if (response.statusCode == 200) {
    //   return 'Failed update all data';
    // }
    else {
      throw Exception('Failed to post list.');
    }
  }

  List encondeToJson(List<ScanModel> list) {
    List jsonList = [];
    list.map((item) => jsonList.add(item.toMap())).toList();
    return jsonList;
  }

}