import 'package:flutter/material.dart';
import 'package:writerapp/db/file_db.dart';


class PageViewr extends StatefulWidget {

  PageViewr({Key? key}) : super(key: key);

  @override
  _PageViewrState createState() => _PageViewrState();
}


class _PageViewrState extends State<PageViewr> {
  @override
  Widget build(BuildContext context) {
    double textsixe = 15;
    double textheight = 1.5;
    final filedata = ModalRoute.of(context)!.settings.arguments as FileArguments;

      return SafeArea(
        child: Container(
            child: Scaffold(
            appBar: AppBar(
                  title: Text(filedata.title),
                ),
              body: Container(
                child: SingleChildScrollView(
                child: Container(child: Text(
                  filedata.content,
                  style: TextStyle(fontSize: textsixe, height: textheight),),
                  color: Colors.transparent,
                  padding: EdgeInsetsDirectional.fromSTEB(15, 15, 15, 30)
                ),
                ),

                decoration: BoxDecoration(
              // borderRadius: BorderRadius.all(Radius.circular(15.0)),
              image: DecorationImage(
              image: AssetImage('assets/old_paper.png'),
              fit: BoxFit.cover,
            ),
          ),
              )
          ),
        )
      );
  }
}






