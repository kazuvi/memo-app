import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:io';

import 'package:writerapp/db/folder_db.dart';

class MainFile {
  final int? id;
  final int? folderId;
  String title;
  String content;
  final bool isDone;
  final DateTime createdAt;
  final DateTime updateAt;

  MainFile({this.id, this.folderId ,this.title = "", this.content ="", this.isDone = false, required this.createdAt, required this.updateAt});

  MainFile.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'] as int,
        folderId = map['folderId'] as int,
        title = map['title'] as String,
        content = map['content'] as String,
        isDone = map['isDone'] == 1,
        createdAt =
          DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        updateAt =
          DateTime.fromMillisecondsSinceEpoch(map['updateAt'] as int);

  Map<String, dynamic> toJsonMap() => {
        'id': id,
        'folderId': folderId,
        'title': title,
        'content': content,
        'isDone': isDone ? 1 : 0,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updateAt': updateAt.millisecondsSinceEpoch,
      };
}

class FileArguments {
  String title;
  final int? id;
  final int? folderId;
  String content;

  FileArguments(this.title, this.id, this.folderId, this.content);
}

class InfolderDb {
  static const kDbFileName = 'protofile.db';
  static const kDbTableName = 'file_tbl';


  late Database _db;
  List<MainFile> files = [];


  // Opens a db local file. Creates the db table if it's not yet created.
  Future<void> initDb() async {
    final dbFile = await getDatabasesPath();
    if (!await Directory(dbFile).exists()) {
      await Directory(dbFile).create(recursive: true);
    }
    final dbPath = join(dbFile, kDbFileName);
    this._db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE $kDbTableName(
          id INTEGER PRIMARY KEY,
          folderId INTEGER,
          isDone BIT NOT NULL,
          title TEXT,
          content TEXT,
          createdAt INT,
          updateAt INT)
        ''');
      },
    );
  }

  Future<List> getFileItems(int? id) async {
    final List<Map<String, dynamic>> jsons =
    await this._db.rawQuery('SELECT * FROM $kDbTableName WHERE folderId=?',[id]);
    files = jsons.map((json) => MainFile.fromJsonMap(json)).toList();
    return files;
  }


    Future<int?> getNowCreateId() async {
    int? id;
    final List<Map<String, dynamic>> jsons =
    await this._db.rawQuery('SELECT * FROM $kDbTableName ORDER BY createdAt desc LIMIT 1');
    id = jsons.map((json) => MainFile.fromJsonMap(json)).toList()[0].id;
    return id;
  }



  Future<void> addFileItem(MainFile file) async {
    await this._db.transaction(
      (Transaction txn) async {
        await txn.rawInsert('''
          INSERT INTO $kDbTableName
            (folderId ,title, content, isDone, createdAt, updateAt)
          VALUES
            (
              "${file.folderId}",
              "${file.title}",
              "${file.content}",
              ${file.isDone ? 1 : 0},
              ${file.createdAt.millisecondsSinceEpoch},
              ${file.updateAt.millisecondsSinceEpoch}
            )''');
      },
    );
  }

  // Deletes records in the db table.
  Future<void> deleteFileItem(MainFile folder) async {
    await this._db.rawDelete('''
        DELETE FROM $kDbTableName
        WHERE id = ${folder.id}
      ''');
  }

    Future<void> deleteAllFile(Folder folder) async {
    await this._db.rawDelete('''
        DELETE FROM $kDbTableName
        WHERE folderId = ${folder.id}
      ''');
  }

  Future<void> updateContent(String content, int? id, int? folderId) async {
    await this._db.rawUpdate(
      /*sql=*/ '''
      UPDATE $kDbTableName
      SET content = ?
      WHERE id = ?''',
      /*args=*/ [content, id],
    );
    final folderdb = new FolderDb();
    await folderdb.initDb();
    folderdb.updateUpdateAt(folderId);
  }

  Future<void> updateName(MainFile file) async {
    await this._db.rawUpdate(
      /*sql=*/ '''
      UPDATE $kDbTableName
      SET title = ?
      WHERE id = ?''',
      /*args=*/ [file.title,file.id],
    );
  }
}