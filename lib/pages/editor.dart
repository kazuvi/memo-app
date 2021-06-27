import 'package:flutter/material.dart';
import 'package:writerapp/db/file_db.dart';
import 'package:writerapp/db/diff_db.dart';

import 'package:async/async.dart';
import 'package:fluttertoast/fluttertoast.dart';



final globalKeyGetTextField = GlobalKey();


class Edit extends StatelessWidget {
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
            // CustomPaint(
            //   painter: TextUnderLinePainter(),
            // ),
            Container(
              child:             TextField(
              key: globalKeyGetTextField,
              keyboardType: TextInputType.multiline,
              maxLines: 30,
                  decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.green,
                    ),
                  ),
                ),
              // decoration: const InputDecoration(border: InputBorder.none),
              controller: TextEditingController(text: getfile.content),
              onChanged: (text) {
                getfile.content = text;
                if (text.length > 10000){
                  Fluttertoast.showToast(msg: '一万文字を超えました　ファイルの分割をおすすめします');
                }
              },
            )),
          ],
        ),
      ),
          backgroundColor: Colors.white.withOpacity(0.8),
          floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.toll_rounded),
              onPressed: () async{
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
              }
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        ),
      ),
    );
  }
}

class TextUnderLinePainter extends CustomPainter {
  TextUnderLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final textFieldRenderBox =
        globalKeyGetTextField.currentContext!.findRenderObject() as RenderBox;

    final ruledLineWidth = textFieldRenderBox.size.width;
    final ruledLineSpace = textFieldRenderBox.size.height / 10000;
    const ruledLineContentPadding = 12;

    final ruledLineHeight = textFieldRenderBox.size.height;
    final ruledLineHSpace = textFieldRenderBox.size.width / 100;

    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    for (var i = 1; i <= 10000; i++) {
      canvas.drawLine(
          Offset(0, ruledLineSpace * i + ruledLineContentPadding),
          Offset(ruledLineWidth, ruledLineSpace * i + ruledLineContentPadding),
          paint);
    }


    // for (var i = 1; i <= 100; i++) {
    //   canvas.drawLine(
    //       Offset(ruledLineHSpace * i + ruledLineContentPadding, 0),
    //       Offset(ruledLineHSpace * i + ruledLineContentPadding, ruledLineHeight),
    //       paint);
    // }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}