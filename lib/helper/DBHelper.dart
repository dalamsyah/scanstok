import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:scanstock/model/m_scan.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DbHelper {

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE scanstock (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        idstokcount TEXT,
        item_code TEXT,
        sn TEXT,
        sn2 TEXT,
        loc TEXT,
        zone TEXT,
        area TEXT,
        rack TEXT,
        bin TEXT,
        scan INTEGER,
        upload INTEGER,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP
      )
      """);
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'scanstock.db',
      version: 2,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item
  static Future<int> createItem(ScanModel object) async {
    final db = await DbHelper.db();
    int id = await db.insert('scanstock', object.toMap(), conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print("id save: $id");
    return id;
  }

  // Read all items
  static Future<List<Map<String, dynamic>>> getItems(String key) async {
    final db = await DbHelper.db();
    return db.query('scanstock', where: "sn = ?", whereArgs: [key], orderBy: "id");
  }

  // Get a single item by id
  //We dont use this method, it is for you if you want it.
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await DbHelper.db();
    return db.query('scanstock', where: "id LIKE ?", whereArgs: [id], limit: 1);
  }

  Future<List<Map<String, dynamic>>> select() async {
    Database db = await DbHelper.db();
    var mapList = await db.query('scanstock', orderBy: 'id');
    return mapList;
  }

  static Future<List<ScanModel>> getList(String key) async {
    Database db = await DbHelper.db();
    var contactMapList = await db.query('scanstock', where: "sn LIKE ?", whereArgs: ['%$key%'], orderBy: "updated_at");

    int count = contactMapList.length;
    List<ScanModel> contactList = [];
    for (int i=0; i<count; i++) {
      contactList.add(ScanModel.fromMap(contactMapList[i]));
    }
    return contactList;
  }

  static Future<List<ScanModel>> getListToUpload() async {
    Database db = await DbHelper.db();
    var contactMapList = await db.query('scanstock', where: "scan > ?", whereArgs: [0]);

    int count = contactMapList.length;
    List<ScanModel> contactList = [];
    for (int i=0; i<count; i++) {
      contactList.add(ScanModel.fromMap(contactMapList[i]));
    }
    return contactList;
  }

  static Future<int> checkPendingUpload() async {
    Database db = await DbHelper.db();
    var contactMapList = await db.query('scanstock', where: "upload = ?", whereArgs: [0]);
    return contactMapList.length;
  }

  // Update an item by id
  static Future<int> updateItem(
      int scan, String snOrSn2, String rackArr) async {
    final db = await DbHelper.db();
    List<String> rack = rackArr.split("-");

    final data = {
      'scan': scan,
      'loc': rack[0],
      'zone': rack[1],
      'area': rack[2],
      'rack': rack[3],
      'bin': rack[4],
      'upload': 0,
      'updated_at': DateTime.now().toString()
    };

    var cek = await db.query('scanstock', where: "sn = ? OR sn2 = ?", whereArgs: [snOrSn2, snOrSn2]);
    if (cek.isEmpty) {
      return -1;
    }

    final result = await db.update('scanstock', data, where: "sn = ? OR sn2 = ?", whereArgs: [snOrSn2, snOrSn2]);
    return result;
  }

  static Future<int> updateStatusUpload(
      String idstokcount) async {
    final db = await DbHelper.db();

    final data = {
      'upload': 1,
    };

    final result = await db.update('scanstock', data, where: "idstokcount = ?", whereArgs: [idstokcount]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await DbHelper.db();
    try {
      await db.delete("scanstock", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }


  static Future<void> delete() async {
    final db = await DbHelper.db();
    try {
      await db.delete("scanstock");
    } catch (err) {
      debugPrint("Something went wrong when deleting all item");
    }
  }

//   static DbHelper _dbHelper;
//   static late Database _database;
//
//   DbHelper._createObject();
//
//   factory DbHelper() {
//     if (_dbHelper == null) {
//       _dbHelper = DbHelper._createObject();
//     }
//     return _dbHelper;
//   }
//
//   Future<Database> initDb() async {
//
//     //untuk menentukan nama database dan lokasi yg dibuat
//     Directory directory = await getApplicationDocumentsDirectory();
//     String path = directory.path + 'scanstock.db';
//
//     //create, read databases
//     var todoDatabase = openDatabase(path, version: 1, onCreate: _createDb);
//
//     //mengembalikan nilai object sebagai hasil dari fungsinya
//     return todoDatabase;
//   }
//
//   //buat tabel baru dengan nama contact
//   void _createDb(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE scanstock (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         idstokcount TEXT,
//         item_code TEXT,
//         sn TEXT,
//         sn2 TEXT,
//         scan TEXT,
//         created_at TEXT,
//         updated_at TEXT,
//       )
//     ''');
//   }
//
//   Future<Database> get database async {
//     if (_database == null) {
//       _database = await initDb();
//     }
//     return _database;
//   }
//

//
// //create databases
//   Future<int> insert(ScanModel object) async {
//     Database db = await this.database;
//     int count = await db.insert('scanstock', object.toMap());
//     return count;
//   }
// //update databases
//   Future<int> update(ScanModel object) async {
//     Database db = await this.database;
//     int count = await db.update('scanstock', object.toMap(),
//         where: 'id=?',
//         whereArgs: [object.id]);
//     return count;
//   }
//
// //delete databases
//   Future<int> delete(int id) async {
//     Database db = await this.database;
//     int count = await db.delete('scanstock',
//         where: 'id=?',
//         whereArgs: [id]);
//     return count;
//   }
//
//   Future<List<ScanModel>> getList() async {
//     var contactMapList = await select();
//     int count = contactMapList.length;
//     List<ScanModel> contactList = [];
//     for (int i=0; i<count; i++) {
//       contactList.add(ScanModel.fromMap(contactMapList[i]));
//     }
//     return contactList;
//   }

}