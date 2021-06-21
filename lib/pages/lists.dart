// import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:writerapp/onp.dart';



class ListTileExample extends StatelessWidget {
  const ListTileExample({Key ?key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final listTiles = <Widget>[
      Card(
      child: ListTile(

        // leading: FlutterLogo(size: 40.0),
        title: Text('Three-line ListTile'),
        subtitle: Text(
          'キンプリ, かおとお\n2021-9-4 08:21'
        ),
        trailing: Icon(Icons.more_vert),
        isThreeLine: true,
        onTap: (){
          
          String bef = "焦点となっていた酒類の制限については、まん延防止措置の期間中でも人数制限などの条件を満たせば午後7時まで可能とし、飲食店の営業は午後8時までとする方向で調整しています。岡山と広島に出されていた緊急事態宣言と岐阜、三重に適用されていたは予定通り20日でそれぞなります。";
          String aft = "焦点となっていた酒類の提供に関する制限については、飲食店の営業は午後8時までとする方向で調整しています。岡山と広島に出されていた緊急事態宣言と岐阜、三重に適用されていたまん延防止措置は予定通り20日でそれぞれ解除となります。";

          var result = onp(bef, aft);
          formatDiff(bef, aft, result);
          Navigator.pushNamed(context, "/list");
        },
      ),
    ),


    ];
    // Directly returning a list of widgets is not common practice.
    // People usually use ListView.builder, c.f. "ListView.builder" example.
    // Here we mainly demostrate ListTile.
    return ListView(children: listTiles);
  }
}