import 'package:flutter/material.dart';
import 'package:getwidget/components/text_field/gf_text_field.dart';
import 'package:scanstock/helper/DBHelper.dart';
import 'package:scanstock/model/m_scan.dart';
import 'package:scanstock/repo/scan_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';


class SettingUrlPage extends StatefulWidget {
  static String tag = 'home-page';
  SettingUrlPage({ Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingUrlPage();
}

class _SettingUrlPage extends State<SettingUrlPage> {
  final TextEditingController _controllerUrl = TextEditingController();

  @override
  Widget build(BuildContext context) {

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


    return Scaffold(
        body: SafeArea(
            child: Column(
              children: [
                Text('Current url: '),
                _url,
                ElevatedButton(
                    onPressed: (){

                    },
                    child: Text('Save')
                )
              ],
            )
        )
    );

}


}