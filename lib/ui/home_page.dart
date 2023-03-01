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
  List<ScanModel> scanList;

  HomePage({ Key? key, required this.scanList}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {

  final _scanService = ScanService();
  final TextEditingController _controllerSearch = TextEditingController();
  final TextEditingController _controllerScanManual = TextEditingController();
  int count = 0;

  @override
  void initState() {
    super.initState();
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
      itemCount: widget.scanList.length,
      itemBuilder: (BuildContext context, int index) {

        var color = Container(
          width: 5,
          height: 50,
          color: Colors.white,
        );
        if (widget.scanList[index].scan > 1) {
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
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("SN: "+this.widget.scanList[index].sn ),
                    Text("SN2: "+this.widget.scanList[index].sn2),
                    Text(""),
                    Text(this.widget.scanList[index].updated_at),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _refreshData(String key) async {
    final data = await DbHelper.getList(key);
    setState(() {
      widget.scanList.clear();
      widget.scanList.addAll( data );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: SafeArea(
          child: Column(
            children: [

              Row(
                children: [
                  Expanded(child:
                    Container(
                      padding: EdgeInsets.only(left: 20, top: 20),
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
                    //search

                    DbHelper.updateItem(2, _controllerScanManual.text.toString()).then((int value) {
                      if (value > 0) {
                        _refreshData('');
                      } else {
                        showAlertDialog(context, 'Data not found.');
                      }
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

              Expanded(
                  child:
                  Container(
                    padding: EdgeInsets.all(10),
                    child: widget.scanList.isEmpty ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No data.')
                      ],
                    ) : createListView(),
                  ),
              ),

              Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: (){
                      showLoaderDialog(context);
                      _scanService.postList(widget.scanList).then((value) {
                        Navigator.pop(context);
                        SnackBar snackBar = SnackBar(
                          content: Text(value),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }).onError((error, stackTrace) {
                        Navigator.pop(context);
                        const snackBar = SnackBar(
                          content: Text('Failed upload data.'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    },
                    child: Text('Upload')
                ),
              )
            ],
          ),
        )
    );

  }

  showAlertDialog(BuildContext context, String msg) {

    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Message"),
      content: Text(msg),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showLoaderDialog(BuildContext context){
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(
            width: 10,
          ),
          Container(
            child:Text(" Loading..." ),
            padding: EdgeInsets.all(10),
          ),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
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