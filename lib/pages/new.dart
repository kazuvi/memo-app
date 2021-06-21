import 'package:flutter/material.dart';

class New extends StatefulWidget {

  @override
  _New createState() => _New();
}

class _New extends State<New> {

  TextEditingController nameController = TextEditingController();
  String UserName = '';


  @override
  Widget build(BuildContext context) {
    return Center(child: Column(children: <Widget>[
            Container(
                margin: EdgeInsets.all(20),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'タイトル',
                  ),
                  onChanged: (text) {
                    setState(() {
                      UserName = text;
                      //you can access nameController in its scope to get
                      // the value of text entered as shown below
                      //UserName = nameController.text;
                    });
                  },
                )),
            Container(
                margin: EdgeInsets.all(20),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'タグ',
                  ),
                  onChanged: (text) {
                    setState(() {
                      UserName = text;
                      //you can access nameController in its scope to get
                      // the value of text entered as shown below
                      //UserName = nameController.text;
                    });
                  },
                )),
          ]),
    );
  }

}