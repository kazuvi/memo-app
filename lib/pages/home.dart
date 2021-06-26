import 'package:flutter/material.dart';

import 'package:async/async.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:writerapp/db/folder_db.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Folder> _files = [];
  final db = new FolderDb();
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm');

  Future<bool> _asyncInit() async {
    await _memoizer.runOnce(() async {
      await db.initDb();
      this._files = await db.getFolderItems()as List<Folder>;
    });
    return true;
  }

  Future<void> _updateUI() async {
    this._files = await db.getFolderItems()as List<Folder>;
    setState(() {});
  }

  Card _itemToListTile(Folder folder) => Card(
    child : InkWell(
      onTap: () async {
        await Navigator.pushNamed(this.context, "/infolder",arguments: FolderArguments(folder.title, folder.id));
        _updateUI();
        setState(() {});
      },
      child: Container(
        // image banner
          // decoration: BoxDecoration(
          //   image: DecorationImage(
          //     image: folder.id == 1 ? AssetImage("assets/500.png") :  AssetImage("assets/kurage.png"),
          //     fit: BoxFit.fitWidth,
          //     alignment: Alignment.topCenter,
          //   ),
          // ),
          child: ListTile(
            title: Text(
              folder.title,
            ),
          subtitle: Text(folder.tags == "" ? '\n最終更新日: ${outputFormat.format(folder.updateAt)}':'Tag: ${folder.tags}\n最終更新日: ${outputFormat.format(folder.updateAt)}'),
          isThreeLine: true,
          trailing:
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () async {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => SimpleDialog(
                title: Text(folder.title),
                children: <Widget>[
                  // ListTile(
                  //   leading: const Icon(Icons.account_circle),
                  //   title: const Text('user@example.com'),
                  //   onTap: () => Navigator.pop(context, 'user@example.com'),
                  // ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('編集'),
                    onTap: () async {
                      Navigator.of(context).pop();
                        showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String title = folder.title;
                        String tags = folder.tags;
                        return AlertDialog(
                          title: Text('編集'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextField(
                                autofocus: true,
                                controller: TextEditingController(text: folder.title),
                                decoration: new InputDecoration(
                                  labelText: 'タイトル'
                                ),
                                onChanged: (value) {
                                  title = value;
                                },
                              ),
                              TextField(
                                controller: TextEditingController(text: folder.tags),
                                decoration: new InputDecoration(
                                  labelText: 'タグ', hintText: '、で区切ってください'
                                ),
                                onChanged: (value) {
                                tags = value;
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
                                folder.title = title;
                                folder.tags = tags;
                                await db.updateNameTag(folder);
                                Navigator.of(context).pop();
                                _updateUI();
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
                          content: const Text('このフォルダのファイルはすべて消去されます'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async{
                                    await db.deleteFolderItem(folder);
                                    _updateUI();
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
                String sortTag = "";
                showDialog<String>(
              context: context,
              builder: (BuildContext context) =>
                AlertDialog(
                  title: Text('タグ検索'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: TextEditingController(text: sortTag),
                        autofocus: true,
                        decoration: new InputDecoration(
                          labelText: 'タグ'
                        ),
                        onChanged: (value) async {
                          if (value != ""){
                          sortTag = value;
                          var isDesc = false;
                          this._files = await db.sortFolderItems(sortTag, isDesc) as List<Folder>;
                          setState(() {});
                          }
                        },
                      ),
                    ]
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
                            );
              }
            ),

            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => SimpleDialog(
                title: const Text('並び替え'),
                children: <Widget>[
                  ListTile(
                    // leading: const Icon(Icons.account_circle),
                    title: const Text('更新日時 昇順'),
                    onTap: ()async {
                      var isDesc = false;
                      this._files = await db.orderUpdateTimeFolderItems(isDesc) as List<Folder>;
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                  ),

                  ListTile(
                    title: const Text('更新日時 降順'),
                    onTap: ()async {
                      var isDesc = true;
                      this._files = await db.orderUpdateTimeFolderItems(isDesc) as List<Folder>;
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                  ),

                  ListTile(
                    title: const Text('作成日時 昇順'),
                    onTap: () async{
                      var isDesc = false;
                      this._files = await db.orderCreateTimeFolderItems(isDesc) as List<Folder>;
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                  ),

                  ListTile(
                    title: const Text('作成日時 降順'),
                    onTap: () async{
                      var isDesc = true;
                      this._files = await db.orderCreateTimeFolderItems(isDesc) as List<Folder>;
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
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
            body: ListView(
              children: this.db.folders.map(_itemToListTile).toList(),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String title = "";
                    String tags = "";
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
                          TextField(
                            decoration: new InputDecoration(
                              labelText: 'タグ', hintText: '、で区切ってください'
                            ),
                            onChanged: (value) {
                            tags = value;
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
                              await db.addFolderItem(
                              Folder(
                              title: title,
                              tags: tags,
                              createdAt: DateTime.now(),
                              updateAt: DateTime.now(),
                              ),
                            );
                          Navigator.of(context).pop(title);
                          await Navigator.pushNamed(this.context, "/infolder",arguments: FolderArguments(title, await db.getNowCreateId()));
                          _updateUI();
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