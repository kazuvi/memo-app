import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:intl/intl.dart';
import 'package:writerapp/pages/file_db.dart';

import 'package:async/async.dart';
import 'package:writerapp/pages/home.dart';
import 'package:writerapp/pages/diff_db.dart';


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

  DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm');

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
            style: TextStyle(
              fontStyle: file.isDone ? FontStyle.italic : null,
              color: file.isDone ? Colors.grey : null,
              decoration: file.isDone ? TextDecoration.lineThrough : null
            ),
          ),
          subtitle: RichText(
            overflow: TextOverflow.ellipsis,
            strutStyle: StrutStyle(fontSize: 10.0),
            text: TextSpan(
              style: TextStyle(color: Colors.black.withOpacity(0.5)),
              text: 'prev: ${file.content.replaceAll('\n', '')}'
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz),
            // onPressed: () async {
            //   await db.deleteFileItem(file);
            //   _updateUI(file.folderId);
            // }
                onPressed: ()async {
                  Navigator.pushNamed(this.context, "/view",arguments: FileArguments(file.title, file.id, file.folderId, file.content));
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
                var diffdb = new DiffmakeDB();
                await diffdb.initDb();
                await diffdb.commit(1, 1, "これはテデフツチオオオです");
                // await diffdb.addFileItem(
                //   DiffFile(
                //     folderId: 1,
                //     folderFileId: "1-1",
                //     title: "test",
                //     content: "これはテストです",
                //     diff: await diffdb.commit(1, 1, "これはテストです"),
                //     createdAt: DateTime.now()

                //   )
                // );
                Navigator.pushNamed(context, "/diffview", arguments: await diffdb.commit(1, 1, "これはテデフツチオオオです"));
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
                await db.addFileItem(
                  MainFile(
                  folderId: getfolderId.folderId,
                  title: "テストです",
                  content: "",
                  createdAt: DateTime.now(),
                  updateAt: DateTime.now(),
                  ),
                );
              _updateUI(getfolderId.folderId);
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