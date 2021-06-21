
import 'package:flutter/material.dart';
import 'package:writerapp/pages/home.dart';
import 'package:writerapp/pages/editor.dart';
import 'package:writerapp/pages/infolder.dart';

void main() => runApp(MaterialApp(
  initialRoute: "/home",
  routes: {
    "/home": (context) => Home(),
    "/editor": (context) => Edit(),
    '/infolder': (context) => Infolder(),
  },
));