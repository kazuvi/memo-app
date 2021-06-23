import 'package:flutter/material.dart';
import 'package:writerapp/db/file_db.dart';

import 'package:async/async.dart';



final globalKeyGetTextField = GlobalKey();

class Edit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final getfile= ModalRoute.of(context)!.settings.arguments as FileArguments;
    print(getfile.content.replaceAll('\n', ''));
    return WillPopScope(
      onWillPop: (){
      Navigator.pop(context, getfile.content);
      return Future.value(false);
    },
      child:
    Container(
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
        body: RuledLineTextField(),
        backgroundColor: Colors.white.withOpacity(0.8),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.toll_rounded),
            onPressed: () => showModalBottomSheet(
                context: context,
                builder: (BuildContext context) => Container(
                  alignment: Alignment.center,
                  height: 200,
                  child: const Text('Dummy bottom sheet'),
                ),
              ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    )
    ,
    );
  }
}

class RuledLineTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

  var getfile= ModalRoute.of(context)!.settings.arguments as FileArguments;
  final db = new InfolderDb();
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future<bool> asyncInit() async {
    await _memoizer.runOnce(() async {
      await db.initDb();
    });
    return true;
  }

  asyncInit();
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: <Widget>[
          CustomPaint(
            painter: TextUnderLinePainter(),
          ),
          TextField(
            key: globalKeyGetTextField,
            keyboardType: TextInputType.multiline,
            maxLines: 10000,
            decoration: const InputDecoration(border: InputBorder.none),
            controller: TextEditingController(text: getfile.content),
            onChanged: (text) {
                getfile.content = text;
                db.updateContent(getfile.content, getfile.id);
                  },
          ),
        ],
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