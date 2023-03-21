import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/components/text_field/gf_text_field.dart';
import 'package:scanstock/helper/DBHelper.dart';
import 'package:scanstock/model/m_scan.dart';
import 'package:scanstock/repo/scan_service.dart';
import 'package:scanstock/ui/setting_url_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  List<ScanModel> scanList;
  String currentRack = "-";
  HomePage({ Key? key, required this.scanList}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {

  final _scanService = ScanService();
  final TextEditingController _controllerSearch = TextEditingController();
  final TextEditingController _controllerScanManual = TextEditingController();
  final TextEditingController _controllerUrl = TextEditingController();
  int count = 0;

  @override
  void initState() {
    super.initState();
  }

  Widget rack(int index) {

    if (widget.scanList[index].zone == "") {
      return const Text("Rack: -");
    }

    return Text("Rack: ${widget.scanList[index].zone} - ${widget.scanList[index].area} - ${widget.scanList[index].bin}");
  }

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
                    Text("SN: ${widget.scanList[index].sn}" ),
                    Text("SN2: ${widget.scanList[index].sn2}"),
                    // Text("Upload: ${widget.scanList[index].upload}"),
                    rack(index),
                    Text(""),
                    Text(widget.scanList[index].updated_at),
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

  void validateScan(String barcode) async {
    if (widget.currentRack == "-") {
      showAlertDialog(context, 'Please Scan Rack first!');
    } else {
      try {

        List<String> list = widget.currentRack.split("-");
        String loc = '';
        String zone = list[0];
        String area = list[1];
        String rack = list[2];
        String bin = list[3];

        showLoaderDialog(context);
        _scanService.postAndFetch(barcode, loc, zone, area, rack, bin).then((value) {
          Navigator.pop(context);
          _refreshData('');
        }).onError((error, stackTrace) {
          Navigator.pop(context);
          const snackBar = SnackBar(
            content: Text('Failed scan item.'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      } on Exception catch (_) {
        showAlertDialog(context, 'Format Current Rack wrong!');
      }
    }
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
                    validateScan(_controllerScanManual.text);

                  }, child: Text('Scan')),
                ],
              ),

              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    child: OutlinedButton(onPressed: () async {
                      String result = await FlutterBarcodeScanner.scanBarcode(
                          '#ff6666',
                          'Batal',
                          false,
                          ScanMode.DEFAULT);
                      setState(() {
                        result = result.replaceAll("]C1", "");
                        widget.currentRack = result;
                      });

                      print("print->"+result);
                    }, child: Text('Scan Rack')),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: OutlinedButton(onPressed: () async {

                      String result = await FlutterBarcodeScanner.scanBarcode(
                          '#ff6666',
                          'Batal',
                          false,
                          ScanMode.DEFAULT);

                      result = result.replaceAll("]C1", "");
                      print("print item->"+result);
                      validateScan(result);


                    }, child: Text('Scan Item')),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    child: Text('Current Rack: ${widget.currentRack}'),
                  )
                ],
              ),

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

            ],
          ),
        )
    );

  }

  showSettingURLDialog(BuildContext context){

    Widget _url = Container(
      child: TextField(
        controller: _controllerUrl,
        keyboardType: TextInputType.text,
        // style: TextStyle(fontSize: 22.0, color: Color(0xffffffff)),
        onChanged: (String value){

        },
        autofocus: false,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search...',
          contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(18.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
      ),
    );

    AlertDialog alert = AlertDialog(
      content: Column(
        children: [
          Text('Current url: '),
          _url,
          ElevatedButton(
              onPressed: (){

              },
              child: Text('Save')
          )
        ],
      ),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
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

extension E on String {
  String lastChars(int n) => substring(length - n);
}