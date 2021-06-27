import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:async/async.dart';
import 'package:fluttertoast/fluttertoast.dart';

// import 'package:writerapp/db/folder_db.dart';
import 'package:writerapp/db/file_db.dart';
import 'package:writerapp/db/diff_db.dart';

class DiffList extends StatefulWidget {
  final int? folderId;
  DiffList({Key ?key, this.folderId}) : super(key: key);
  @override
  _DiffListState createState() => _DiffListState();
}

class _DiffListState extends State<DiffList> {
  List<DiffFile> _files = [];
  final db = new DiffmakeDB();
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm');

  Future<bool> asyncInit(int? folderid, int? fileid) async {
    await _memoizer.runOnce(() async {
      await db.initDb();
      this._files =  await db.getDiffItems(folderid, fileid)as List<DiffFile>;
    });
    return true;
  }

  Future<void> _updateUI(int? folderid, int? fileid) async {
    this._files = await db.getDiffItems(folderid, fileid) as List<DiffFile>;
    setState(() {});
  }

  Card _itemToListTile(DiffFile file) => Card(
    child : InkWell(
      onTap: ()async {
        var result = await Navigator.pushNamed(context, "/diffview", arguments: await db.getPrevFileContent(file.id));
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
            file.message,
          ),
          subtitle: Text('+${file.plusChar} ${file.minusChar}\n${outputFormat.format(file.createdAt)}'),
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
                                file.message = title;
                                // await db.updateName(file);
                                Navigator.of(context).pop();
                                // _updateUI(file.folderFileId);
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
                                    // await db.deleteFileItem(file);
                                    // _updateUI(file.folderId);
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
    final getFileArgs = ModalRoute.of(context)!.settings.arguments as FileArguments;
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
      future: asyncInit(getFileArgs.folderId, getFileArgs.id),
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
                title: Text(getFileArgs.title),
                centerTitle: true,
              ),
            ),
            bottomNavigationBar: bottomNavBar,
            // backgroundColor: Colors.black.withOpacity(0.5),
            body:   ListView(
              children: this._files.map(_itemToListTile).toList(),
            ),
          ),
        );
      },
    );
  }
}