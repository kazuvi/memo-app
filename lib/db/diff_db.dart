
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:writerapp/onp.dart';

import 'dart:io';

class DiffFile {
  final int? id;
  final int? folderId;
  String folderFileId;
  final String title;
  String content;
  String diff;
  String message;
  final int? plusChar;
  final int? minusChar;
  final DateTime createdAt;

  DiffFile({this.id, this.folderId, this.folderFileId = "", this.title = "", this.content ="", this.diff = "", this.message= "", this.plusChar, this.minusChar, required this.createdAt});
  DiffFile.fromJsonMap(Map<String, dynamic> map):
    id = map['id'] as int,
    folderId = map['folderId'] as int,
    folderFileId = map['folderFileId'] as String,
    title = map['title'] as String,
    content = map['content'] as String,
    diff = map['diff'] as String,
    message = map['message'] as String,
    plusChar = map['plusChar'] as int,
    minusChar = map['minusChar'] as int,
    createdAt =
    DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int);
  Map<String, dynamic> toJsonMap() => {
    'id': id,
    'folderId': folderId,
    'folderFileId': folderFileId,
    'title': title,
    'content': content,
    'diff': diff,
    "message": message,
    "plusChar": plusChar,
    "minusChar": minusChar,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };
}


class DiffmakeDB {
  static const kDbFileName = 'diff_demo2.db';
  static const kDbTableName = 'diff_tbl';
  late Database _db;
  List<DiffFile> files = [];

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
          folderFileId TEXT,
          title TEXT,
          content TEXT,
          diff TEXT,
          message TEXT,
          plusChar INTEGER,
          minusChar INTEGER,
          createdAt INT
          )
        ''');
      },
    );
  }
  Future<List> getDiffItems(int? folderid, int? fileid) async {
    String strfolderid = folderid.toString();
    String strfileid = fileid.toString();
    String folderfileid = "$strfolderid-$strfileid";
    final List<Map<String, dynamic>> jsons =
    await this._db.rawQuery('SELECT * FROM $kDbTableName WHERE folderFileId=?',[folderfileid]);
    files = jsons.map((json) => DiffFile.fromJsonMap(json)).toList();
    return files;
  }

  Future<String>  getPrevFileContent(int? id) async {
    final List<Map<String, dynamic>> jsons =
    await this._db.rawQuery('SELECT * FROM $kDbTableName WHERE id=?',[id]);
    files = jsons.map((json) => DiffFile.fromJsonMap(json)).toList();
    return files[0].diff;
  }

  Future<List>  getPrevFiles(int? folderid, int? fileid) async {
    String strfolderid = folderid.toString();
    String strfileid = fileid.toString();
    String folderfileid = "$strfolderid-$strfileid";
    final List<Map<String, dynamic>> jsons =
    await this._db.rawQuery('SELECT * FROM $kDbTableName WHERE folderFileId=? ORDER BY id desc LIMIT 1',[folderfileid]);
    files = jsons.map((json) => DiffFile.fromJsonMap(json)).toList();
    return files;
  }
  Future<List> commit(int? folderId, int? fileid, String currContent) async {
    String prevContent;
    await this.getPrevFiles(folderId, fileid);
    if (this.files.length == 0) {
      prevContent = "";
    }else {
      prevContent = this.files[0].content;
    }
    List diffitems = getDiff(prevContent, currContent);
    diffitems[0].replaceAll('@|sprite|@@|sprite|@', '@|sprite|@');
    return diffitems;
  }

  Future<void> addFileItem(DiffFile file) async {
    await this._db.transaction(
      (Transaction txn) async {
        await txn.rawInsert('''
          INSERT INTO $kDbTableName
            (folderId, folderFileId, title, content, diff, message, plusChar, minusChar, createdAt)
          VALUES
            (
              "${file.folderId}",
              "${file.folderFileId}",
              "${file.title}",
              "${file.content}",
              "${file.diff}",
              "${file.message}",
              "${file.plusChar}",
              "${file.minusChar}",
              ${file.createdAt.millisecondsSinceEpoch}
            )''');
      },
    );
  }
}