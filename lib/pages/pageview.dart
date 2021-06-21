import 'package:flutter/material.dart';

class ContentSliverList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index % 2 == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            );
          } else {
            return _buildHorizontalPageView(context, 4);
          }
        },
        childCount: 2,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
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