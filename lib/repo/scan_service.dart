
import 'package:scanstock/helper/DBHelper.dart';
import 'package:scanstock/model/m_scan.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ScanService {

  List<ScanModel> listScan = [];
  bool isLoading = false;

  Future<List<ScanModel>> getScanList() async {

    isLoading = true;

    SharedPreferences localStorage = await SharedPreferences.getInstance();

    final response = await http.get(Uri.parse('http://192.168.56.1/scan_barcode_stok_api/public/scan'));

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      var list = data['data'] as List;

      listScan = list.map((data) => ScanModel.fromMap(data) ).toList();

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

}