import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:io';
import 'package:writerapp/db/file_db.dart';
// import 'package:writerapp/db/diff_db.dart';

class Folder {
  final int? id;
  final String title;
  final String tags;
  final bool isDone;
  final DateTime createdAt;
  final DateTime updateAt;


  Folder({this.id, this.title = "", this.tags ="", this.isDone = false, required this.createdAt, required this.updateAt});

  Folder.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'] as int,
        title = map['title'] as String,
        tags = map['tags'] as String,
        isDone = map['isDone'] == 1,
        createdAt =
          DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        updateAt =
          DateTime.fromMillisecondsSinceEpoch(map['updateAt'] as int);

  Map<String, dynamic> toJsonMap() => {
        'id': id,
        'title': title,
        'tags': tags,
        'isDone': isDone ? 1 : 0,
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
  static const kDbFileName = 'proto.db';
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
          isDone BIT NOT NULL,
          title TEXT,
          tags TEXT,
          createdAt INT,
          updateAt INT)
        ''');
      },
    );
  }

  // Retrieves rows from the db table.
  Future<List> getFolderItems() async {
    final List<Map<String, dynamic>> jsons =
    await this._db.rawQuery('SELECT * FROM $kDbTableName');
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
            (title, tags, isDone, createdAt, updateAt)
          VALUES
            (
              "${folder.title}",
              "${folder.tags}",
              ${folder.isDone ? 1 : 0},
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
}