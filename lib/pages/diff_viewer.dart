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
    return new Column(children: strings.map((item) => new Container(
      height: 30,
      width: 400,
      color: item.substring(0,1) == "+" ? Colors.green[300]: item.substring(0,1) == "-" ? Colors.red[300] : Colors.white,
      child: Text(item),

    )).toList());
  }
}


