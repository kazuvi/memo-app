import 'package:flutter/material.dart';
import 'package:writerapp/db/file_db.dart';
import 'package:writerapp/db/diff_db.dart';
import 'package:async/async.dart';



final globalKeyGetTextField = GlobalKey();

class Edit extends StatefulWidget {
  final int? folderId;
  Edit({Key ?key, this.folderId}) : super(key: key);
  @override
  _EditState createState() => _EditState();
}

var menuposition = 0;

class _EditState extends State<Edit> {
  @override
  Widget build(BuildContext context) {
    final getfile= ModalRoute.of(context)!.settings.arguments as FileArguments;
    final db = new InfolderDb();
    final AsyncMemoizer _memoizer = AsyncMemoizer();
    var onScreen = true;

    Future<bool> asyncInit() async {
      await _memoizer.runOnce(() async {
        await db.initDb();
      });
      return true;
    }

    timer(db) async {
      while (onScreen == true) {
      await Future.delayed(Duration(seconds: 1));
      db.updateContent(getfile.content, getfile.id, getfile.folderId);
      }
    }

    timer(db);
    asyncInit();

    return WillPopScope(
      onWillPop: () {
      Navigator.pop(context, getfile.content);
      onScreen = false;
      return Future.value(false);
    },
      child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/test.png'),
          fit: BoxFit.cover,
        ),
      ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(getfile.title),
          ),
        body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            Container(
              child: TextField(
              // autofocus: true,
              key: globalKeyGetTextField,
              keyboardType: TextInputType.multiline,
              maxLines: 30,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                ),
              decoration: const InputDecoration(border: InputBorder.none),
              controller: TextEditingController(text: getfile.content),
              onChanged: (text) {
                getfile.content = text;
              },
            )),
          ],
        ),
      ),
          backgroundColor: Colors.white.withOpacity(0.8),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(top: 80),
              child: Draggable(
                feedback: FloatingActionButton(child: Icon(Icons.drag_handle), onPressed: () {}),
                child: FloatingActionButton(child: Icon(Icons.drag_handle), onPressed: () async{
                var diffdb = new DiffmakeDB();
                await diffdb.initDb();
                Future<List> list = diffdb.commit(getfile.folderId, getfile.id, getfile.content);
                List diffitems = await list ;
                await diffdb.addFileItem(
                  DiffFile(
                    folderId: getfile.folderId,
                    folderFileId: getfile.folderId.toString() + "-" + getfile.id.toString(),
                    title: getfile.title,
                    content: getfile.content,
                    diff: diffitems[0],
                    message: "insaert message",
                    plusChar: diffitems[1],
                    minusChar: diffitems[2],
                    createdAt: DateTime.now()
                  )
                );
              }),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  var viewArea = MediaQuery.of(context).size;
                  var keyboardArea = MediaQuery.of(context).viewInsets.bottom;
                  // 初期値右下　0
                  //下側処理
                  if (details.offset.dy > viewArea.height/2 - keyboardArea/2) {
                    // 左寄
                    if (details.offset.dx > MediaQuery.of(context).size.width/2) {
                      menuposition = 0;
                      setState(() {});
                    } else {
                      menuposition = 1;
                      setState(() {});
                    }
                  } else {
                    // 左寄
                    if (details.offset.dx > MediaQuery.of(context).size.width/2) {
                      menuposition = 3;
                      setState(() {});
                    } else {
                      menuposition = 2;
                      setState(() {});
                    }
                  }
                }
              ),
          ),
            floatingActionButtonLocation: menuposition == 0 ? FloatingActionButtonLocation.endFloat: menuposition == 1 ? FloatingActionButtonLocation.startFloat: menuposition == 2 ? FloatingActionButtonLocation.startTop : FloatingActionButtonLocation.endTop,
        ),
      ),
    );
  }
}