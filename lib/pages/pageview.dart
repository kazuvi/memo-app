import 'package:flutter/material.dart';
import 'package:writerapp/db/file_db.dart';

class ContentSliverList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fileData = ModalRoute.of(context)!.settings.arguments as FileArguments;
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
                          return _buildHorizontalPageView(context, 55);
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

  Widget _buildHorizontalPageView(BuildContext context, int itemCount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          // you may want to use an aspect ratio here for tablet support
          height: MediaQuery.of(context).size.height,
          child:
          PageView.builder(
            itemCount: itemCount,
            controller: PageController(viewportFraction: 1),
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildHorizontalItem(context, itemCount, itemIndex);
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  fileData.title,
                  textAlign: TextAlign.left,
                  // overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w200, color: Colors.white, height: 2, fontSize: 24),
                ),
                Text(
                  fileData.content,
                  // textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w100, color: Colors.white, height: 2, fontSize: 14),
                ),
              ]
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
          )
        ],
      ),
    );
  }
}