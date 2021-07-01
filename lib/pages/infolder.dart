import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:async/async.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:writerapp/db/folder_db.dart';
import 'package:writerapp/db/file_db.dart';
import 'package:writerapp/db/diff_db.dart';

class Infolder extends StatefulWidget {
  final int? folderId;
  Infolder({Key ?key, this.folderId}) : super(key: key);
  @override
  _InfolderState createState() => _InfolderState();
}

class _InfolderState extends State<Infolder> {
  List<MainFile> _files = [];
  final db = new InfolderDb();
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm');

  Future<bool> asyncInit(int? getid) async {
    await _memoizer.runOnce(() async {
      await db.initDb();
      this._files =  await db.getFileItems(getid)as List<MainFile>;
    });
    return true;
  }

  Future<void> _updateUI(int? id) async {
    this._files = await db.getFileItems(id) as List<MainFile>;
    setState(() {});
  }

  Card _itemToListTile(MainFile file) => Card(
    child : InkWell(
      onTap: ()async {
        var result = await Navigator.pushNamed(this.context, "/editor",arguments: FileArguments(file.title, file.id, file.folderId, file.content));
        file.content = result as String;
        setState(() {});
      },
    child: Container(

        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("assets/500.png"),
        //     fit: BoxFit.fitWidth,
        //     alignment: Alignment.topCenter,
        //   ),
        // ),

        child: ListTile(
          title: Text(
            file.title,
            style: TextStyle(fontSize: 16),
          ),
          subtitle: Text('${file.content.length}字\n${file.content.length <= 15 ? file.content.replaceAll("\n", "") :file.content.replaceAll("\n", "").substring(0, 15) + "..."}',
          style: TextStyle(height: 1.2),
          ),
          trailing:
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () async {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => SimpleDialog(
                title: Text(file.title),
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: const Text('閲覧'),
                    onTap: ()async {
                      if (file.content == ""){
                        Fluttertoast.showToast(msg: "本文が空です");
                      } else {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(this.context, "/view",arguments: FileArguments(file.title, file.id, file.folderId, file.content));
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('更新履歴'),
                    onTap: ()async {
                      var diffdb = new DiffmakeDB();
                      await diffdb.initDb();
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, "/difflist", arguments: FileArguments(file.title, file.id, file.folderId, file.content));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('編集'),
                    onTap: () async {
                      Navigator.of(context).pop();
                        showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String title = file.title;
                        return AlertDialog(
                          title: Text('編集'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextField(
                                autofocus: true,
                                controller: TextEditingController(text: file.title),
                                decoration: new InputDecoration(
                                  labelText: 'タイトル'
                                ),
                                onChanged: (value) {
                                  title = value;
                                },
                              ),
                            ]
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text("キャンセル"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: Text('更新'),
                              onPressed: () async {
                                file.title = title;
                                await db.updateName(file);
                                Navigator.of(context).pop();
                                _updateUI(file.folderId);
                              },
                            ),
                          ],
                        );
                        },
                      );
                    }
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('削除'),
                    onTap: () async{
                      Navigator.of(context).pop();
                      showDialog(context: context,
                        builder:  (BuildContext context) => AlertDialog(
                          content: Text('${file.title} を消去します'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async{
                                    await db.deleteFileItem(file);
                                    _updateUI(file.folderId);
                                    Navigator.of(context).pop();
                                },
                                child: const Text('Ok'),
                              ),
                            ],
                      ));
                    },
                  ),
                ],
              ),
            ).then((returnVal) {
              if (returnVal != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You clicked: $returnVal'),
                    action: SnackBarAction(label: 'OK', onPressed: () {}),
                  ),
                );
              }
            });
          },
          ),
        ),
      )
    )
  );

  @override
  Widget build(BuildContext context) {
    final getfolderId = ModalRoute.of(context)!.settings.arguments as FolderArguments;
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
              onPressed: () async {
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => Fluttertoast.showToast(msg: 'Dummy menu action.'),
            ),
          ],
        ),
      );

    return FutureBuilder<bool>(
      future: asyncInit(getfolderId.folderId),
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
              preferredSize: Size.fromHeight(50.0),
              child: AppBar(
                title: Text(getfolderId.title),
                centerTitle: true,
              ),
            ),
            bottomNavigationBar: bottomNavBar,
            // backgroundColor: Colors.black.withOpacity(0.5),
            body:   ListView(
              children: this._files.map(_itemToListTile).toList(),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String title = "";
                          return AlertDialog(
                            title: Text('新規作成'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextField(
                                  autofocus: true,
                                  decoration: new InputDecoration(
                                    labelText: 'タイトル'
                                  ),
                                  onChanged: (value) {
                                    title = value;
                                  },
                                ),
                              ]
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () => Navigator.of(context).pop(title),
                              ),
                              TextButton(
                                child: Text('Ok'),
                                onPressed: () async {
                                  await db.addFileItem(
                                    MainFile(
                                      folderId: getfolderId.folderId,
                                      title: title,
                                      content: "",
                                      createdAt: DateTime.now(),
                                      updateAt: DateTime.now(),
                                    ),
                                  );
                                Navigator.of(context).pop(title);
                                  await Navigator.pushNamed(this.context, "/editor",arguments: FileArguments(title, await db.getNowCreateId(), getfolderId.folderId, ""));
                                  _updateUI(getfolderId.folderId);
                                  setState(() {});
                                },
                              ),
                            ],
                          );
                        },
                      );
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