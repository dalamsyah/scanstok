import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:scanstock/helper/DBHelper.dart';
import 'package:scanstock/model/m_scan.dart';
import 'package:scanstock/repo/scan_service.dart';
import 'package:scanstock/ui/home_page.dart';
import 'package:scanstock/ui/setting_url_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static String tag = 'my-app';
  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,

      ),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const MyHomePage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/setting': (context) => SettingUrlPage(),
      },
    );
  }


}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool _iSearch = false;
  final _scanService = ScanService();
  final TextEditingController _controllerSearch = TextEditingController();
  final TextEditingController _controllerUrl = TextEditingController();
  List<ScanModel> scanList = [];

  getURL() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('url') ?? ScanService().baseUrl;
    _controllerUrl.text = stringValue;
    return stringValue;
  }

  void _refreshData(String key) async {
    final data = await DbHelper.getList(key);
    setState(() {
      scanList = data;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getURL();
    _refreshData('');
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
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(18.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
      ),
    );

    AlertDialog alert = AlertDialog(
      title: Text('URL'),
      content: _url,
      actions: [
        ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              SharedPreferences localStorage = await SharedPreferences.getInstance();
              localStorage.setString("url", _controllerUrl.text);
            },
            child: Text('Save')
        )
      ],
    );
    showDialog(barrierDismissible: true,
      context:context,
      builder:(BuildContext context){
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

  showProgress(bool loading) {
    if (loading){
      return Dialogs.materialDialog(
          context: context,
          barrierDismissible: false,
          actions: [
            Container(
              child: Column(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 10,),
                  Text('Please wait'),
                ],
              ),
            )
          ]
      );
    } else {
      return Container();
    }
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

  @override
  Widget build(BuildContext context) {

    Widget _search = Container(
      child: TextField(
        controller: _controllerSearch,
        keyboardType: TextInputType.text,
        // style: TextStyle(fontSize: 22.0, color: Color(0xffffffff)),
        onChanged: (String value){
          _refreshData(value);
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
      appBar: AppBar(
          title: _iSearch ? _search : Text('Scan Stock'),
          actions: [
            // Navigate to the Search Screen
            !_iSearch ?
            IconButton(
                onPressed: (() {
                  setState(() {
                    _iSearch = !_iSearch;
                  });
                }),
                icon: const Icon(Icons.search)) :
            IconButton(
                onPressed: () {
                  setState(() {
                    _iSearch = !_iSearch;
                    _controllerSearch.text = '';
                  });
                },
                icon: const Icon(Icons.cancel)),
            PopupMenuButton(onSelected: (result) async {
              if (result == 1) {
                showSettingURLDialog(context);
              } else if (result == 2) {
                // showLoaderDialog(context);
                // showProgress(true);
                showLoaderDialog(context);
              }
            }, itemBuilder: (context) => [
              PopupMenuItem(child: Text('Setting URL'), value: 1, onTap: (){

              }),

            ],
            )
          ]
      ),
      body: HomePage(scanList: scanList),
    );
  }

}
