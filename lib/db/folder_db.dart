import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:io';
import 'package:writerapp/db/file_db.dart';
// import 'package:writerapp/db/diff_db.dart';

class Folder {
  final int? id;
  String title;
  String tags;
  final DateTime createdAt;
  final DateTime updateAt;


  Folder({this.id, this.title = "", this.tags ="",  required this.createdAt, required this.updateAt});

  Folder.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'] as int,
        title = map['title'] as String,
        tags = map['tags'] as String,
        createdAt =
          DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        updateAt =
          DateTime.fromMillisecondsSinceEpoch(map['updateAt'] as int);

  Map<String, dynamic> toJsonMap() => {
        'id': id,
        'title': title,
        'tags': tags,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updateAt': updateAt.millisecondsSinceEpoch,
      };
}

class FolderArguments {
  final String title;
  final int? folderId;

  FolderArguments(this.title, this.folderId);
}

class FolderDb {
  static const kDbFileName = 'folder_demo.db';
  static const kDbTableName = 'folder_tbl';

  late Database _db;
  List<Folder> folders = [];

  // Opens a db local file. Creates the db table if it's not yet created.
  Future<void> initDb() async {
    final dbFolder = await getDatabasesPath();
    if (!await Directory(dbFolder).exists()) {
      await Directory(dbFolder).create(recursive: true);
    }
    final dbPath = join(dbFolder, kDbFileName);
    this._db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE $kDbTableName(
          id INTEGER PRIMARY KEY,
          title TEXT,
          tags TEXT,
          createdAt INT,
          updateAt INT)
        ''');
      },
    );
  }

  Future<List> getFolderItems() async {
    final List<Map<String, dynamic>> jsons =
    await this._db.rawQuery('SELECT * FROM $kDbTableName ORDER BY updateAt DESC');
    folders = jsons.map((json) => Folder.fromJsonMap(json)).toList();
    return folders;
  }

    Future<int?> getNowCreateId() async {
    int? id;
    final List<Map<String, dynamic>> jsons =
    await this._db.rawQuery('SELECT * FROM $kDbTableName ORDER BY createdAt DESC LIMIT 1');
    id = jsons.map((json) => Folder.fromJsonMap(json)).toList()[0].id;
    return id;
  }

  Future<void> addFolderItem(Folder folder) async {
    await this._db.transaction(
      (Transaction txn) async {
        await txn.rawInsert('''
          INSERT INTO $kDbTableName
            (title, tags,  createdAt, updateAt)
          VALUES
            (
              "${folder.title}",
              "${folder.tags}",
              ${folder.createdAt.millisecondsSinceEpoch},
              ${folder.updateAt.millisecondsSinceEpoch}
            )''');
      },
    );
  }

  // Deletes records in the db table.
  Future<void> deleteFolderItem(Folder folder) async {
    await this._db.rawDelete('''
      DELETE FROM $kDbTableName
      WHERE id = ${folder.id}
      ''');
    final filedb = new InfolderDb();
    await filedb.initDb();
    filedb.deleteAllFile(folder);
  }

    Future<void> updateUpdateAt(int? folderId) async {
    await this._db.rawUpdate(
      /*sql=*/ '''
      UPDATE $kDbTableName
      SET updateAt = ?
      WHERE id = ?''',
      /*args=*/ [DateTime.now().millisecondsSinceEpoch, folderId],
    );
  }

    Future<void> updateNameTag(Folder folder) async {
    await this._db.rawUpdate(
      /*sql=*/ '''
      UPDATE $kDbTableName
      SET title = ?, tags = ?
      WHERE id = ?''',
      /*args=*/ [folder.title, folder.tags, folder.id],
    );
  }

    Future<List> orderCreateTimeFolderItems(bool isDesc) async {
    final List<Map<String, dynamic>> jsons =
    await this._db.rawQuery(isDesc ? 'SELECT * FROM $kDbTableName ORDER BY createdAt DESC' :'SELECT * FROM $kDbTableName ORDER BY createdAt');
    folders = jsons.map((json) => Folder.fromJsonMap(json)).toList();
    return folders;
  }

      Future<List> orderUpdateTimeFolderItems(bool isDesc) async {
    final List<Map<String, dynamic>> jsons =
    await this._db.rawQuery(isDesc ? 'SELECT * FROM $kDbTableName ORDER BY updateAt DESC' :'SELECT * FROM $kDbTableName ORDER BY updateAt');
    folders = jsons.map((json) => Folder.fromJsonMap(json)).toList();
    return folders;
  }

  Future<List> sortFolderItems(String tag, isDesc) async {
    final List<Map<String, dynamic>> jsons =
    await this._db.rawQuery('SELECT * FROM $kDbTableName WHERE tags LIKE ?',[tag]);
    folders = jsons.map((json) => Folder.fromJsonMap(json)).toList();
    return folders;
  }
}