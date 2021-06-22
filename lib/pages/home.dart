import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:async/async.dart';
import 'dart:io';

import 'package:intl/intl.dart';



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

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  static const kDbFileName = 'proto.db';
  static const kDbTableName = 'folder_tbl';
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  late Database _db;
  List<Folder> _folders = [];

  // Opens a db local file. Creates the db table if it's not yet created.
  Future<void> _initDb() async {
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
  Future<void> _getFolderItems() async {
    final List<Map<String, dynamic>> jsons =
    await this._db.rawQuery('SELECT * FROM $kDbTableName');
    this._folders = jsons.map((json) => Folder.fromJsonMap(json)).toList();
  }

  // Inserts records to the db table.
  // Note we don't need to explicitly set the primary key (id), it'll auto
  // increment.
  Future<void> _addFolderItem(Folder folder) async {
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

  // Updates records in the db table.
  Future<void> _toggleTodoItem(Folder todo) async {
    await this._db.rawUpdate(
      /*sql=*/ '''
      UPDATE $kDbTableName
      SET isDone = ?
      WHERE id = ?''',
      /*args=*/ [if (todo.isDone) 0 else 1, todo.id],
    );
  }

  // Deletes records in the db table.
  Future<void> _deleteFolderItem(Folder folder) async {
    await this._db.rawDelete('''
      DELETE FROM $kDbTableName
      WHERE id = ${folder.id}
      ''');
  }

  Future<bool> _asyncInit() async {
    await _memoizer.runOnce(() async {
      await _initDb();
      await _getFolderItems();
    });
    return true;
  }

  Future<void> _updateUI() async {
    await _getFolderItems();
    setState(() {});
  }

  DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm');


  Card _itemToListTile(Folder folder) => Card(
    child : InkWell(
      onTap: () {
        Navigator.pushNamed(this.context, "/infolder",arguments: FolderArguments(folder.title, folder.id));
      },
    child: Container(

      // image banner
        decoration: BoxDecoration(
          image: DecorationImage(
            image: folder.id == 1 ? AssetImage("assets/500.png") :  AssetImage("assets/kurage.png"),
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
        ),

        child: ListTile(
        title: Text(
        folder.title,
        style: TextStyle(
          fontStyle: folder.isDone ? FontStyle.italic : null,
          color: folder.isDone ? Colors.grey : null,
          decoration: folder.isDone ? TextDecoration.lineThrough : null
        ),
      ),
      subtitle: Text('タグ: ${folder.tags}\n最終更新日: ${outputFormat.format(folder.createdAt)}'),
      isThreeLine: true,
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () async {
          await _deleteFolderItem(folder);
          _updateUI();
        }
      ),
    ),
    )
    )
  );


  @override
  Widget build(BuildContext context) {
    final bottomNavBar = BottomAppBar(
      shape:  const CircularNotchedRectangle(),
      color: Theme.of(context).primaryColor,
        child: Row(
          children: <Widget>[
            // Bottom that pops up from the bottom of the screen.
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (BuildContext context) => Container(
                  alignment: Alignment.center,
                  height: 200,
                  child: const Text('Dummy bottom sheet'),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () =>
                  Fluttertoast.showToast(msg: 'Dummy search action.'),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => Fluttertoast.showToast(msg: 'Dummy menu action.'),
            ),
          ],
        ),
      );

    return FutureBuilder<bool>(
      future: _asyncInit(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == false) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Container(

              // decoration: BoxDecoration(
              //   image: DecorationImage(
              //     image: AssetImage('assets/kurage.png'),
              //     fit: BoxFit.cover,
              //   ),
              // ),

              child: Scaffold(
                  appBar: PreferredSize(
                    // backgroundColor: Colors.black.withOpacity(0.7),
                    preferredSize: Size.fromHeight(40.0),
                    child: AppBar(
                    ),
                  ),
                  bottomNavigationBar: bottomNavBar,
                  // backgroundColor: Colors.black.withOpacity(0.5),
                  body:
                    // CustomScrollView(
                    // slivers: [ContentSliverList()],),
                  ListView(
                    children: this._folders.map(_itemToListTile).toList(),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () async {
                      await _addFolderItem(
                        Folder(
                        title: "テストです",
                        tags: "呪術",
                        createdAt: DateTime.now(),
                        updateAt: DateTime.now(),
                        ),
                      );
                    _updateUI();
                    },
                    child: const Icon(Icons.add),
                  ),
                  floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              ),
            );
      },
    );
  }
}