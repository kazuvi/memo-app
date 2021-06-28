
import 'package:flutter/material.dart';
import 'package:writerapp/db/file_db.dart';

class ContentSliverList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return Container(
            child: Scaffold(
                // appBar: PreferredSize(
                //   // backgroundColor: Colors.black.withOpacity(0.7),
                //   preferredSize: Size.fromHeight(40.0),
                //   child: AppBar(
                //     title: Text(fileData.title),
                //   ),
                // ),
                body:
                  CustomScrollView(
                  slivers: [SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (index % 2 == 0) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          );
                        } else {
                          return _buildHorizontalPageView(context);
                        }
                      },
                      childCount: 2,
              ),
            )
          ],
        ),
      ),
    );
  }

  int maxlines = 19;
  int maxstring_1line = 23;

  pagecreate(String content){
    List lines = [];
    List retu = [];
    int mod = content.length % maxstring_1line;
    int split20 = mod == 0 ?content.length ~/ maxstring_1line: content.length ~/ maxstring_1line + 1;
    var eva = "";

    for (int i = 0; i < split20; i++){
      var c = i * maxstring_1line;
      var splitter = 0;
      if (c + maxstring_1line > content.length){
        splitter = content.length;
      } else {
        splitter = maxstring_1line + c;
      }
      lines.add(content.substring(0 + c, splitter));
      var nowline = lines[i].toString().replaceAll("\n", "@|@splitter@|@").split("@|@splitter@|@");
      var len = nowline.length;
      if (len > 1){
        for (int g = 0; g < len; g++ ){
          if (g == len - 1 && nowline[len - 1] != "") {
            eva = nowline[g];
          } else {
            var cre = eva + nowline[g];
            if (cre.length > maxstring_1line){
              var sp1 = cre.substring(0, maxstring_1line);
              var sp2 = cre.substring(maxstring_1line, cre.length);
              retu.add(sp1);
              retu.add(sp2);
            } else if (cre != ""){
              retu.add(cre);
            }
            eva = "";
            retu.add("\n");
          }
        }
      } else {
        retu.add(nowline[0]);
      }
    }
    if (eva != ""){
      retu.add(eva);
    }
    var complist = making(retu);
    return complist;
  }

  making(List list){
    var count =0;
    List complist = [];
    var page = "";

    for (int i =0; i< list.length; i++){
      if (count == maxlines){
        complist.add(page);
        page = "";
        count = 0;
      }
      if (list[i] == "\n" && list[i-1] != "\n"){
        page = page + "\n";
      }
      page = page + list[i];
      if (list[i].length == maxstring_1line){
        page = page + "\n";
      }
      count += 1;
    }
    if (page != "") {
      complist.add(page);
    }
    return complist;
  }

    Widget _buildHorizontalPageView(BuildContext context) {
    final fileData = ModalRoute.of(context)!.settings.arguments as FileArguments;
    List page = pagecreate(fileData.content);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          // you may want to use an aspect ratio here for tablet support
          height: MediaQuery.of(context).size.height,
          child:
          PageView.builder(
            reverse: false,
            itemCount: page.length,
            controller: PageController(viewportFraction: 1),
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildHorizontalItem(context, page.length, itemIndex);
            },
          )
          ,
        )
      ],
    );
  }

  Widget _buildHorizontalItem(
    BuildContext context, int carouselIndex, int itemIndex) {
    final fileData = ModalRoute.of(context)!.settings.arguments as FileArguments;
    var pageNum = itemIndex + 1;
    List page = pagecreate(fileData.content);

    return SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  itemIndex == 0 ? fileData.title: "",
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, height: 2, fontSize: 24),
                ),
                Text(
                  page[itemIndex],
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w100, color: Colors.black, height: 2, fontSize: 14),
                ),
                Text("P.${pageNum.toString()} / ${carouselIndex.toString()}"),
              ]
            ),
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            width: MediaQuery.of(context).size.width,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              image: DecorationImage(
              image: AssetImage('assets/old_paper.png'),
              fit: BoxFit.cover,
            ),
          ),

          )
        ],
      ),
    )
    );
  }
}