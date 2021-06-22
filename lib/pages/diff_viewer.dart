import 'package:flutter/material.dart';

var list = [
  "私が何を言っているのか分かっているのか",
  "+もう彼には何も聞こえない",
  "-彼は何も聞こうとしない",
  "その衝動が彼を襲う"];

class DiffViewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
        return SafeArea(
        child: Container(
            child: Scaffold(
              appBar: PreferredSize(
                  // backgroundColor: Colors.black.withOpacity(0.7),
                  preferredSize: Size.fromHeight(40.0),
                  child: AppBar(
                  ),
                ),
                body: getTextWidgets(list)

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


