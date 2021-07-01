import 'package:flutter/material.dart';

class DiffViewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final diff = ModalRoute.of(context)!.settings.arguments as String;
    List<String> sprr = diff.split("@|sprite|@");
    if (sprr[0] == "") {
      sprr.removeAt(0);
    }
    if (sprr[sprr.length - 1] == "") {
      sprr.removeAt(sprr.length - 1);
    }

      return SafeArea(
        child: Container(
            child: Scaffold(
            appBar: PreferredSize(
                // backgroundColor: Colors.black.withOpacity(0.7),
                preferredSize: Size.fromHeight(40.0),
                child: AppBar(
                ),
              ),
              body: getTextWidgets(sprr)
          ),
        )
      );
  }

  Widget getTextWidgets(List<String> strings)
  {
    return new ListView(children: strings.map((item) => new Container(
      padding: EdgeInsets.all(16.0),
      color: item.length < 13 ? Colors.white : item.substring(0,12) == "@|plusdiff|@" ? Colors.green[100]: item.substring(0,13) == "@|minusdiff|@" ? Colors.red[100] : Colors.white,
      child: Text(item.length < 13 ? item : item.substring(0,12) == "@|plusdiff|@" ? item.replaceAll("@|plusdiff|@", "+ ") : item.substring(0,13) == "@|minusdiff|@" ? item.replaceAll("@|minusdiff|@", "-  ") : item, style: TextStyle(fontSize: 16, height: 1.5),),
    )).toList());
  }

}






