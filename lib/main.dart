import 'package:flutter/material.dart';
import 'package:writerapp/pages/home.dart';
import 'package:writerapp/pages/editor.dart';
import 'package:writerapp/pages/infolder.dart';
import 'package:writerapp/pages/pageview.dart';
import 'package:writerapp/pages/diff_viewer.dart';


void main() => runApp(MaterialApp(
  initialRoute: "/home",
  routes: {
    "/home": (context) => Home(),
    "/editor": (context) => Edit(),
    '/infolder': (context) => Infolder(),
    '/view': (context)  => ContentSliverList(),
    '/diffview': (context)  => DiffViewer(),
  },
));