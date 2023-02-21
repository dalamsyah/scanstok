import 'package:flutter/material.dart';
import 'package:getwidget/components/text_field/gf_text_field.dart';
import 'package:scanstock/helper/DBHelper.dart';
import 'package:scanstock/model/m_scan.dart';
import 'package:scanstock/repo/scan_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  @override
  State<StatefulWidget> createState() => _HomePage();

}

class _HomePage extends State<HomePage> {

  final _scanService = ScanService();
  final TextEditingController _controllerSearch = TextEditingController();
  final TextEditingController _controllerScanManual = TextEditingController();
  int count = 0;
  List<ScanModel> scanList = [];

  @override
  void initState() {
    super.initState();
    _refreshData('');
  }

  void _refreshData(String key) async {
    final data = await DbHelper.getList(key);
    setState(() {
      scanList = data;
    });
  }

  // void updateListView() {
  //   final Future<Database> dbFuture = dbHelper.initDb();
  //   dbFuture.then((database) {
  //     Future<List<ScanModel>> contactListFuture = dbHelper.get();
  //     contactListFuture.then((list) {
  //       setState(() {
  //         this.scanList = list;
  //         this.count = list.length;
  //       });
  //     });
  //   });
  // }

  ListView createListView() {

    return ListView.builder(
      itemCount: scanList.length,
      itemBuilder: (BuildContext context, int index) {

        var color = Container(
          width: 5,
          height: 50,
          color: Colors.white,
        );
        if (scanList[index].scan > 1) {
          color = Container(
            width: 5,
            height: 50,
            color: Colors.green,
          );
        }

        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: Row(
            children: [
              color,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(this.scanList[index].sn ),
                  Text(this.scanList[index].sn2),
                  Text('Scan ${this.scanList[index].scan}'),
                  Text(this.scanList[index].updated_at),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: GFTextField(
                  controller: _controllerSearch,
                  keyboardType: TextInputType.text,
                  onChanged: (String value){
                    _refreshData(value);
                  },
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0)),
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(child:
                    Container(
                      padding: EdgeInsets.only(left: 20),
                      child: GFTextField(
                        controller: _controllerScanManual,
                        keyboardType: TextInputType.text,
                        onChanged: (String value){

                        },
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'Scan manual',
                          contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0)),
                        ),
                      ),
                    )
                  ),
                  TextButton(onPressed: (){
                    DbHelper.updateItem(2, _controllerScanManual.text.toString()).then((int value) {
                      if (value > 0) {
                        _refreshData('');
                      }
                      debugPrint('update -> $value');
                    });

                  }, child: Text('Scan')),
                ],
              ),

              TextButton(onPressed: () async {
                await FlutterBarcodeScanner.scanBarcode(
                    '#ff6666',
                    'Batal',
                    false,
                    ScanMode.DEFAULT);
              }, child: Text('Open Scanner')),

              TextButton(onPressed: (){
                _scanService.getScanList().then((value) {
                  _refreshData('');
                });
              }, child: Text('Get Data')),

              Expanded(
                  child:
                  createListView(),
              ),
            ],
          ),
        )
    );

  }

  Widget widgetListDocument(int index) {

    return Container(
      child: Column(
        children: [
          Text(_scanService.listScan[index].sn),
        ],
      ),
    );

  }

}